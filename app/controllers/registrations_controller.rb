class RegistrationsController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]

  def edit
    @user = current_user
    @account = current_user.account
  end

  def update
    @user = current_user
    @account = current_user.account

    if @user.update_attributes(registration_params)
      flash[:notice] = 'Update successfuly'
      redirect_to edit_user_registration_path
    else
      flash.now[:alert] = @user.errors.to_a
      render :edit
    end
  end

  private

  def registration_params
    params.require(:user).permit(:username, :email, :password, :avatar)
  end
end
