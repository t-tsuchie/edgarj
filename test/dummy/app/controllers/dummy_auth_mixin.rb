# Authentication Module just for Test
#
# Since user is in outside app of Edgarj, authentication module at controller
# should also provided by the app.
#
# Application should provide:
# * current_user
#   * this should be alos helper method
#
# NOTE: require_login is not mandatory, but required for just test.
module DummyAuthMixin
  def self.included(klass)
    klass.helper_method :current_user
  end

  private

  def access_denied
    flash.now[:error] = v('login_failed')
    render text: nil, response: 400
  end

  def current_user
    @current_user ||=
        if Rails.env == 'development'
          User.find_by_code('root')
        else
          User.find(session[:user_id]) if session[:user_id]
        end
  end

  # before_filter to enforce a login requirement.
  def require_login
    !!current_user || access_denied
  end
end
