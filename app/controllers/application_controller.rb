class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include Proactives::Modules::Controller::Authenticable
  #Crowdbotics
  

  rescue_from Proactives::Errors::UserNotAuthenticated, with: :after_authentication_fail

  def current_user
     @current_user ||= Account.first
  end

  def after_authentication_fail(_error)
    flash[:alert] = 'Authentication required! Please sign in or sign up!'
    redirect_to root_path
  end

  def invalid_token_error(_error)
    sign_out_user
    flash[:alert] = 'Session expired. Please sign in.'
    redirect_to root_path
  end
end
