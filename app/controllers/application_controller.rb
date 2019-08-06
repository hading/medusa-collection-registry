class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :medusa_user?, :safe_can?

  before_action :try_to_establish_session_from_passive_shibboleth

  protected

  def set_current_user(user)
    @current_user = user
    session[:current_user_id] = user.id
  end

  def unset_current_user
    @current_user = nil
    session[:current_user_id] = nil
  end

  def current_user
    @current_user ||= User.find_by(id: session[:current_user_id])
  end

  def current_user_uid
    current_user.uid
  end

  def medusa_user?
    logged_in? and Application.group_resolver.is_ad_user?(current_user)
  end

  def require_medusa_user
    unless medusa_user?
      redirect_non_medusa_user
    end
  end

  def require_medusa_user_or_basic_auth
    unless medusa_user? or basic_auth?
      redirect_non_medusa_user
    end
  end

  def redirect_non_medusa_user
    if current_user
      redirect_to unauthorized_net_id_url(net_id: current_user.net_id)
    else
      redirect_non_logged_in_user
    end
  end

  def redirect_non_logged_in_user
    session[:login_return_uri] = request.env['REQUEST_URI']
    respond_to do |format|
      format.js do
        render 'shared/unauthenticated'
      end
      format.html do
        redirect_to(login_path)
      end
      format.json do
        redirect_to(login_path)
      end
    end
  end

  def logged_in?
    current_user.present?
  end

  def require_logged_in
    redirect_non_logged_in_user unless logged_in?
  end

  def require_logged_in_or_basic_auth
    redirect_non_logged_in_user unless logged_in? or basic_auth?
  end

  def basic_auth?
    ActionController::HttpAuthentication::Basic.decode_credentials(request) == Settings.medusa.basic_auth
  rescue
    false
  end

  rescue_from CanCan::AccessDenied do
    redirect_to unauthorized_path
  end

  rescue_from ActiveRecord::InvalidForeignKey do |exception|
    redirect_back(fallback_location: root_path,
                  alert: 'The record you are trying to delete has some associated database records so cannot be deleted. Please contact the medusa admins for help.')
  end

  def record_event(eventable, key, user = current_user)
    eventable.events.create(actor_email: user.email, key: key, date: Date.today)
  end

  def reset_ldap_cache(user)
    user ||= current_user
    LdapQuery.reset_cache(user.net_id) if user.present?
  end

  #Use in place of Cancan's can? so that it will work when there is not a user (in this case permission is denied, as you'd expect)
  def safe_can?(action, *args)
    current_user and can?(action, *args)
  end

  def try_to_establish_session_from_passive_shibboleth
    Rails.logger.error "EPPN: #{request.env['HTTP_EPPN']}"
    return if current_user
    if session[:checked_shibboleth_passive].present?
      if request.env['HTTP_EPPN'].present?
        session[:login_return_uri] = request.env['REQUEST_URI']
        redirect_to SessionsController.shibboleth_login_path(MedusaCollectionRegistry::Application.shibboleth_host)
      end
    else
      session[:checked_shibboleth_passive] = true
      session[:login_return_uri] = request.env['REQUEST_URI']
      redirect_to SessionsController.shibboleth_login_path(MedusaCollectionRegistry::Application.shibboleth_host,
                                                           passive: true, target_path: request.env['REQUEST_URI'])
    end

  end

end
