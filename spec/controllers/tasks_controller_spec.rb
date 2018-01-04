require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  describe "GET #index" do
    before(:each) { get :index }
    it { should respond_with :ok }
    it { should render_template "index" }
  end

  describe "GET #new" do
    before { get :new }
    it { should render_template "new" }
    it { should respond_with :ok }
  end

  describe "POST #create" do
    before(:each) { @params = { task: { name: 'Test', priority: 1 }, category: '' } }
    it do
      should permit(:name, :priority).for(:create, verb: :post, params: @params).on(:task)
    end

    context "given valid task" do
      it do
        post :create, { params: @params }
        should redirect_to tasks_path
      end

      context "given one new category" do
        before(:each) { post :create, { params: { task: { name: 'Test', priority: 1 }, category: 'asd' } } }
        it { should redirect_to tasks_path }
        it 'should result in Category.find_by(name: "asd").tasks.count to eq 1' do
          expect(Category.find_by(name: 'asd').tasks.count).to eq(1)
        end
        it 'should result in Task.find_by(name:"test").categories.count to eq 1' do
          expect(Task.find_by(name: 'Test').categories.count).to eq(1)
        end
      end

      context "given multiple new categories" do
        before(:each) { post :create, { params: { task: { name: 'Test', priority: 1 }, category: 'asd,anu' } } }
        it { should redirect_to tasks_path }
        it 'should result in Category.find_by(name: "asd").tasks.count to eq 1' do
          expect(Category.find_by(name: 'asd').tasks.count).to eq(1)
        end
        it 'should result in Category.find_by(name: "anu").tasks.count to eq 1' do
          expect(Category.find_by(name: 'anu').tasks.count).to eq(1)
        end
        it 'should result in Task.find_by(name:"test").categories.count to eq 2' do
          expect(Task.find_by(name: 'Test').categories.count).to eq(2)
        end
      end

      context "given a mix of new and exiting categories" do

      end

      context "given existing category" do

      end


    end

    context "given invalid task" do
      before(:each) do
        post :create, { params: { task: { name: 'Test', priority: 0 }, category: '' } }
      end
      it { should respond_with :bad_request }
      it { should render_template "new" }
    end
  end

  describe "GET #edit" do
    before(:each) { @task = Task.create(name: 'Test', priority: 1) }

    context "given valid id" do
      before(:each) { get :edit, params: { id: @task.id } }
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

    context "given one less category" do
        
    end

    context "given a mix of new and exiting categories" do

    end
  end

  describe "POST #update" do

  end

  describe "DELETE #destroy" do
    before(:each) { @task = Task.create(name: 'Test', priority: 1) }
    it do
      expect { 
        delete :destroy, params: { id: @task.id }
      }.to change { Task.count }.by(-1)
    end
    it do
      delete :destroy, params: { id: @task.id }
      should redirect_to(tasks_path)
    end
  end

  describe "POST #done" do
    before(:each) { @task = Task.create(name: 'Test', priority: 1) }
    context "given valid id" do
      before { post :done, { params: { id: @task.id, value: true } }}
      it { should respond_with :ok }
      it { expect(response.body).to eq({ success: true, name: @task.name, value: "true" }.to_json) }
    end

    context "given invalid id" do

    end
  end
end
