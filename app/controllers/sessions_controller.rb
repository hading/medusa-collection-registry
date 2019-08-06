class SessionsController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :try_to_establish_session_from_passive_shibboleth
  delegate :shibboleth_login_path, to: :class

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
    elsif session[:attempting_passive_shibboleth_login]
      session[:attempting_passive_shibboleth_login] = false
      redirect_to session[:login_return_uri]
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

  def self.shibboleth_login_path(host, passive: false)
    passive = !!passive #just normalizing this
    "/Shibboleth.sso/Login?target=https://#{host}/auth/shibboleth/callback&isPassive=#{passive}"
  end

  protected

  def clear_and_return_return_path
    return_url = session[:login_return_uri] || session[:login_return_referer] || root_path
    session[:login_return_uri] = session[:login_return_referer] = nil
    reset_ldap_cache(current_user)
    reset_session
    return_url
  end


end