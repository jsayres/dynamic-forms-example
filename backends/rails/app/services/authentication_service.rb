class AuthenticationService

  def initialize(cookies)
    @cookies = cookies
  end

  def authenticate(username, password)
    user = User.find_by(username: username)
    (user && user.authenticate(password)) || false
  end

  def log_in(user)
    s = Session.create(user: user)
    @cookies[:session_key] = { value: s.key, httponly: true }
  end

  def authenticate_and_log_in(username, password)
    user = authenticate(username, password)
    log_in(user) if user
    user
  end

  def log_out
    @cookies.delete(:session_key)
  end

  def current_user
    unless @current_user
      s = Session.includes(:user).find_by(key: @cookies[:session_key])
      @current_user = s ? s.user : nil
    end
    @current_user
  end

  def logged_in?
    current_user.present?
  end

end
