class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user
      flash[:primary] = "Welcome back!"
      redirect_to tasks_path
    else
      flash.now[:danger] = "Wrong username and/or password"
      render "new", status: :bad_request
    end
  end

  def destroy
    log_out
    flash[:success] = "You have been logged out"
    redirect_to login_path
  end
end
