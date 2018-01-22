# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    @user = User.find params[:id]
  end

  def new
    @user = User.new
  end

  def create
    user = User.new user_params
    if user.save
      redirect_to user
    else
      @user = user
      flash[:error] = user.errors.full_messages.join(", ")
      render "new", status: :bad_request
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :name, :password, :password_confirmation)
    end
end
