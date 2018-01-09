require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  describe "GET #index" do
    before { get :index }
    it { should render_template "index" }
    it { should respond_with :ok }
  end

  describe "GET #show" do
    before(:each) do
      @cat1 = Category.create(name: '1')
      @cat2 = Category.create(name: '2')
    end
    describe "categories/all" do
      before(:each) { get :show, params: { id: 'all' }, format: :json }
      it { should respond_with :ok }
      it { expect(response.body).to eq(Category.all.map { |e| e.name }.to_a.to_json) }
    end
    describe "else" do
      before(:each) { get :show, params: { id: @cat1.id }, format: :json }
      it { should respond_with :no_content }
      it { expect(response.body).to eq("") }
    end
  end

  describe "GET #new" do
    before { get :new }
    it { should render_template "new" }
    it { should respond_with :ok }
  end

  describe "POST #create" do
    before(:each) { @params = { category: { name: 'Test'}, task: '' } }

    it { should permit(:name).for(:create, verb: :post, params: @params).on(:category) }
    
    context "given valid category" do
      it do
        post :create, { params: @params }
        should redirect_to categories_path
      end
    end
    
    context "given invalid category" do
      before(:each) do
        Category.create(name: "Test")
        post :create, { params: @params }
      end
      it { should respond_with :bad_request }
      it { should render_template "new" }
    end   
  end

  describe "GET #edit" do
    before(:each) { @category = Category.create(name: "Test") }

    context "given valid id" do
      before(:each) { get :edit, params: { id: @category.id } }

      it { should respond_with :ok }
      it { should render_template "edit" }
    end

    context "given invalid id" do
      it do
        expect {
          get :edit, params: { id: 'unknown' }
        }.to raise_error(ActiveRecord::RecordNotFound) 
      end
    end
  end

  describe "POST #update" do
    before(:each) do
      @category = Category.create(name: "Test")
      @category2 = Category.create(name: "Test2")
    end
    it do
      should permit(:name).
        for(:update, verb: :post, params: { id: @category.id, category: { name: "NewTest"}, task: '' } ).
        on(:category)
    end
    context "given valid new name" do
      before(:each) do
        post :update, { params: { id: @category.id, category: { name: "NewTest" }, task: '' } }
      end
      it { should redirect_to categories_path }
    end
    context "given invalid new name" do
      before(:each) do
        post :update, { params: { id: @category.id, category: { name: "Test2" }, task: '' } }
      end
      it { should respond_with :bad_request }
      it { should render_template "edit" }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @category = Category.create(name: "Test")
    end
    it do
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
