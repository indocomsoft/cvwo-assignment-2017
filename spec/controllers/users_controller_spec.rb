# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "GET #show" do
    context "logged in" do
      before(:each) do
        @user = User.create(email: "anu@abc.com", password: "123456")
        request.session[:user_id] = @user.id
        get :show, params: { id: @user.id }
      end
      it { should respond_with :ok }
      it { should render_template "show" }
    end
    context "unauthenticated" do
      before(:each) do
        request.session.delete(:user_id)
        get :show, params: { id: "unknown" }
      end
      it { should redirect_to login_path }
    end
  end

  describe "GET #new" do
    context "unauthenticated" do
      before(:each) { get :new }
      it { should render_template "new" }
      it { should respond_with :ok }
    end
    context "logged in" do
      it do
        @user = User.create(email: "anu@abc.com", password: "123456")
        request.session[:user_id] = @user.id
        get :new
        should redirect_to tasks_path
      end
    end
  end

  describe "POST #create" do
    context "unauthenticated" do
      it do
        should permit(:email, :name, :password, :password_confirmation).
          for(:create, verb: :post, params: { user: { email: "anu@abc.com", password: "123456", password_confirmation: "123456" } }).
          on(:user)
      end
      context "given valid input" do
        before(:each) do
          post :create, params: { user: { email: "anu@abc.com", password: "123456", password_confirmation: "123456" } }
          @user = User.find_by(email: "anu@abc.com")
        end
        it { should redirect_to tasks_path }
      end
      context "given invalid input" do
        before(:each) do
          post :create, params: { user: { email: "anu" } }
        end
        it { should respond_with :bad_request }
        it { should render_template "new" }
      end
    end
    context "logged in" do
      before(:each) do
        @user = User.create(email: "anu@abc.com", password: "123456")
        request.session[:user_id] = @user.id
        post :create, params: { user: { email: "aaa@abc.com", password: "123456", password_confirmation: "123456" } }
      end
      it { should redirect_to tasks_path }
      it { expect(User.all.count).to eq(1) }
    end
  end

  describe "GET #edit" do
    before(:each) do
      @user = User.create(email: "anu@abc.com", password: "123456")
      request.session[:user_id] = @user.id
    end
    context "details" do
      before(:each) { get :edit, params: { id: "unknown", change: "details" } }
      it { should render_template "edit" }
      it { should respond_with :ok }
    end
    context "password" do
      before(:each) { get :edit, params: { id: "unknown", change: "password" } }
      it { should render_template "edit" }
      it { should respond_with :ok }
    end
  end

  describe "POST #update" do
    context "details" do
      before(:each) do
        @user = User.create(email: "anu@abc.com", password: "123456")
        request.session[:user_id] = @user.id
        post :update, params: { id: @user.id, change: "details", user: { name: "asd" } }
      end
      it { should redirect_to user_path(@user) }
    end
    context "password" do
      before(:each) do
        @user = User.create(email: "anu@abc.com", password: "123456")
        request.session[:user_id] = @user.id
        post :update, params: { id: @user.id, change: "password", user: { current_password: "123456", password: "asdfgh", password_confirmation: "asdfgh" } }
      end
      it { should redirect_to user_path(@user) }
    end
    context "wrong password" do
      before(:each) do
        @user = User.create(email: "anu@abc.com", password: "123456")
        request.session[:user_id] = @user.id
        post :update, params: { id: @user.id, change: "password", user: { current_password: "12346", password: "asdfgh", password_confirmation: "asdfgh" } }
      end
      it { should render_template "edit" }
      it { should respond_with :bad_request }
    end
  end
end
