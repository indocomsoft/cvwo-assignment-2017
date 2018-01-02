require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  # it do
  #   params = { category: { name: 'Test' } }
  #   should permit(:name).for(:create, verb: :post, params: params).on(:category)
  # end

  describe "POST #create" do
    before(:each) do
      @params = { category: { name: 'Test'} }
    end
    it do
      should permit(:name).for(:create, verb: :get, params: @params).on(:category)
    end
    it "should redirect to /categories if successful" do
      post :create, { params: @params }
      should redirect_to categories_path
    end
    it "should fail if a given name already existed" do
      Category.create(name: "Test")
      post :create, { params: @params }
      should respond_with :bad_request
    end
  end

  describe "GET #edit" do
    before(:each) do
      @category = Category.create(name: "Test")
    end
    it do
      get :edit, params: { id: @category.id }
      should respond_with :ok
    end
    it do
      expect {
        get :edit, params: { id: 'unknown' }
      }.to raise_error(ActiveRecord::RecordNotFound) 
    end
  end

  describe "POST #update" do
    before(:each) do
      @category = Category.create(name: "Test")
    end

  end

  describe "GET #index" do
    before { get :index }
    it { should respond_with :ok }
  end

  describe "GET #new" do
    before { get :new }
    it { should respond_with :ok}
  end

  describe "DELETE #destroy" do
    before(:each) do
      @category = Category.create(name: "Test")
    end
    it "destroys successfully" do
      expect { 
        delete :destroy, params: { id: @category.id }
      }.to change { Category.count }.by(-1)
    end
    it do
      delete :destroy, params: { id: @category.id }
      should redirect_to(categories_path)
    end
  end
end
