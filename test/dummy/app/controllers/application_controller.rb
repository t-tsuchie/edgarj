class ApplicationController < ActionController::Base
  include Edgarj::ControllerMixinForApp
  include DummyAuthMixin
  include Edgarj::RescueMixin

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # order is important.  *Latter* should be more specific.
  rescue_from StandardError,                with: :edgarj_rescue_app_error
  rescue_from ActiveRecord::RecordNotFound, with: :edgarj_rescue_404

  before_filter :require_login
end
