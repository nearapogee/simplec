class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user

  before_action :authenticate_user!
  before_action :require_admin!
  before_action :require_sysadmin!
  before_action :add_subpages!

  rescue_from User::Unauthenticated,
    with: :unauthenticated!
  rescue_from User::Unauthorized,
    with: :unauthorized!

  private

  def sign_in!(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def sign_out!
    session.destroy
    @current_user = nil
  end

  def current_user
    return @current_user if @current_user
    return unless session[:user_id]
    @current_user = User.find_by(id: session[:user_id])
  end

  def authenticate_user!
    raise User::Unauthenticated unless current_user
  end

  def require_admin!
    authenticate_user!
    raise User::Unauthorized unless current_user.admin? || current_user.sysadmin?
  end

  def require_sysadmin!
    authenticate_user!
    raise User::Unauthorized unless current_user.sysadmin?
  end

  def add_subpages!
    @pages = Simplec::Admin::Page.all # this works the same without Admin, is one more correct than the other?
  end

  def unauthenticated!
    Rails.logger.info("Unauthenticated.")
    respond_to do |format|
      format.html {
        flash[:warning] = "You must be logged in to do that."
        redirect_to new_admin_session_url
      }
      format.js { head 401 }
      format.json { head 401 }
    end
  end

  def unauthorized!
    Rails.logger.info("Unauthorized.")
    respond_to do |format|
      format.html {
        flash[:warning] = "You don't have permission to do that."
        redirect_to admin_root_url
      }
      format.js { head 401 }
      format.json { head 401 }
    end
  end
end
