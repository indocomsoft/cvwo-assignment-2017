# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  before(:each) do
    @user = User.create(email: "test@example.com", password: "123456")
    request.session[:user_id] = @user.id
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "valid login details" do
      before(:each) do
        post :create, params: { session: { email: @user.email, password: @user.password } }
      end
      it { should redirect_to tasks_path }
    end
    context "invalid" do
      before(:each) do
        post :create, params: { session: { email: "anu", password: "abc" } }
      end
      it { should respond_with :bad_request }
      it { should render_template :new }
    end
  end

  describe "DELETE #destroy" do
    it do
      delete :destroy
      should redirect_to login_path
    end
  end

end
