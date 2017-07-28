class AccountsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @account = current_user.account
  end

  def edit
    @user = current_user
    @account = current_user.account
  end
end
