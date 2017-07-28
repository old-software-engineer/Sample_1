class SessionsController < ApplicationController
  def new
    if current_user.present? && current_user.account
      redirect_to account_path(current_user.account)
    end
  end

  def create
    redirect_to_login_page
  end

  def callback
    debugger

    sign_in_user(code: params[:code])
    debugger
    account = current_user#.find_or_create_account
    #account.proactives_access_token = current_user.access_token
    #account.save
    flash[:notice] = 'Signed in!'
    redirect_to account_path(account)
  rescue Proactives::Errors::UserNotAuthenticated
    flash[:error] = 'Cannot authenticate the user!'
    redirect_to new_user_session_path
  end

  def destroy
    sign_out_user
    flash[:success] = 'Logout successfully.'
    redirect_to new_user_session_path
  end

  protected

  def callback_url
    user_session_callback_url
  end
end
