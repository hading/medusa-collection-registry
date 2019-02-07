class SessionsController < ApplicationController

  skip_before_action :verify_authenticity_token

  def new
    session[:login_return_referer] = request.env['HTTP_REFERER']
    if Rails.env.production?
      redirect_to(shibboleth_login_path(MedusaCollectionRegistry::Application.shibboleth_host))
    else
      redirect_to('/auth/developer')
    end
  end

  def create
    #auth_hash[:uid] should have the uid (for shib as configured in shibboleth.yml)
    #auth_hash[:info][:email] should have the email address
    auth_hash = request.env['omniauth.auth']
    if auth_hash and auth_hash[:uid]
      return_url = clear_and_return_return_path
      user = User.find_or_create_by!(uid: auth_hash[:uid], email: auth_hash[:info][:email])
      reset_ldap_cache(user)
      set_current_user(user)
      redirect_to return_url
    else
      redirect_to login_url
    end
  end

  def destroy
    unset_current_user
    clear_and_return_return_path
    redirect_to root_url
  end

  def unauthorized

  end

  def unauthorized_net_id
    @net_id = params[:net_id]
  end

  def new_saml
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def create_saml
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => saml_settings)

    # We validate the SAML Response and check if the user already exists in the system
    if response.is_valid?
      render plain: response.inspect
      # authorize_success, log the user
      #session[:userid] = response.nameid
      #session[:attributes] = response.attributes
    else
      #authorize_failure  # This method shows an error message
    end
  end

  def saml_settings
    idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
    idp_metadata_parser.parse(File.read('/etc/shibboleth/itrust-metadata.xml'),
                              entity_id: "urn:mace:incommon:uiuc.edu").tap do |settings|
      settings.soft = false
      settings.certificate = File.read('/etc/shibboleth/sp-cert.pem')
      settings.private_key = File.read('/home/lib-medusa-collectionregistry/etc/sp-key.pem')
      settings.assertion_consumer_service_url = "https://medusatest.library.illinois.edu/login_create_saml"
      #settings.issuer = "https://medusa-dev.library.illinois.edu/shibboleth"
      #settings.issuer                         = "http://#{request.host}/saml/metadata"
      settings.name_identifier_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:transient"
    end
    # OneLogin::RubySaml::Settings.new.tap do |settings|
    #   settings.soft = false
    #   #settings.assertion_consumer_service_url = "http://#{request.host}/saml/consume"
    #   #settings.assertion_consumer_service_url = "https://#{request.host}/login_create_saml"
    #   # settings.issuer                         = "http://#{request.host}/saml/metadata"
    #   # settings.idp_entity_id                  = "https://app.onelogin.com/saml/metadata/#{OneLoginAppId}"
    #   # settings.idp_sso_target_url             = "https://app.onelogin.com/trust/saml2/http-post/sso/#{OneLoginAppId}"
    #   # settings.idp_slo_target_url             = "https://app.onelogin.com/trust/saml2/http-redirect/slo/#{OneLoginAppId}"
    #   # settings.idp_cert_fingerprint           = OneLoginAppCertFingerPrint
    #   # settings.idp_cert_fingerprint_algorithm = "http://www.w3.org/2000/09/xmldsig#sha1"
    #   #settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    #
    #   # Optional for most SAML IdPs
    #   #settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    #   # or as an array
    #   # settings.authn_context = [
    #   #     "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport",
    #   #     "urn:oasis:names:tc:SAML:2.0:ac:classes:Password"
    #   # ]
    #
    #   # Optional bindings (defaults to Redirect for logout POST for acs)
    #   # settings.single_logout_service_binding      = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
    #   # settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"


  end


  protected

  def clear_and_return_return_path
    return_url = session[:login_return_uri] || session[:login_return_referer] || root_path
    session[:login_return_uri] = session[:login_return_referer] = nil
    reset_ldap_cache(current_user)
    reset_session
    return_url
  end

  def shibboleth_login_path(host)
    "/Shibboleth.sso/Login?target=https://#{host}/auth/shibboleth/callback"
  end

end