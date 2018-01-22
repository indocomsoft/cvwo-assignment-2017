# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  before_action :require_login

  private

    def require_login
      if !logged_in?
        flash[:danger] = "You need to log in first"
        redirect_to login_path
      end
    end
    helper_method :require_login
end
