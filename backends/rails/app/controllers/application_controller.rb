class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from User::NotLoggedIn, with: :not_logged_in
  rescue_from User::NotAuthorized, with: :not_authorized

  helper_method :current_user, :logged_in?

  def current_user
    auth.current_user
  end

  def logged_in?
    auth.logged_in?
  end

  def render_403_page
    render "static_pages/403.html", status: 403
  end

  def render_404_page
    render "static_pages/404.html", status: 404
  end
  
  def render_500_page
    render "static_pages/500.html", status: 500
  end

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  private

  def require_login
    raise User::NotLoggedIn unless auth.logged_in?
  end

  def require_staff_or_admin
    require_login
    ok = auth.current_user && auth.current_user.active && (auth.current_user.staff ||
                                                           auth.current_user.admin)
    raise User::NotAuthorized unless ok
  end

  def not_logged_in
    respond_to do |format|
      format.json { render json: {error: "You must log in."}, status: 401 }
      format.html { redirect_to login_path(next: request.path) }
    end
  end

  def not_authorized
    respond_to do |format|
      format.json { render json: {error: "You are not authorized."}, status: 403 }
      format.html { render_403_page }
    end
  end

  def auth
    @auth ||= AuthenticationService.new(cookies)
  end

end
