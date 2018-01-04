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
    it do
      should permit(:name, :priority).
        for(:create, verb: :post, params: { task: { name: 'Test', priority: 1 }, category: '' }).
        on(:task)
    end

    context "given valid task" do
      context "given no category" do
        before(:each) { post :create, { params: { task: { name: 'Test', priority: 1 }, category: '' } } }
        it { should redirect_to tasks_path }
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

      context "given a mix of new and existing, unassociated categories" do
        before(:each) do
          @category = Category.create(name: 'anu')
          post :create, { params: { task: { name: 'Test', priority: 1 }, category: 'asd,anu' } }
        end
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

      context "given a mix of new and existing, already associated categories" do
        before(:each) do
          @category = Category.create(name: 'anu')
          @task = Task.create(name: 'ExistingTask', priority: 1)
          Taskcategory.create(task: @task, category: @category)
          post :create, { params: { task: { name: 'Test', priority: 1 }, category: 'asd,anu' } }
        end
        it { should redirect_to tasks_path }
        it 'should result in Category.find_by(name: "asd").tasks.count to eq 1' do
          expect(Category.find_by(name: 'asd').tasks.count).to eq(1)
        end
        it 'should result in Category.find_by(name: "anu").tasks.count to eq 2' do
          expect(Category.find_by(name: 'anu').tasks.count).to eq(2)
        end
        it 'should result in existing task to still be associated to existing category' do
          expect(@task.categories.first.name).to eq("anu")
        end
        it 'should result in Task.find_by(name:"test").categories.count to eq 2' do
          expect(Task.find_by(name: 'Test').categories.count).to eq(2)
        end
      end

      context "given existing category" do
        before(:each) do
          @category = Category.create(name: 'asd')
          post :create, { params: { task: { name: 'Test', priority: 1 }, category: 'asd' } }
        end
        it { should redirect_to tasks_path }
        it 'should result in Category.find_by(name: "asd").tasks.count to eq 1' do
          expect(Category.find_by(name: 'asd').tasks.count).to eq(1)
        end
        it 'should result in Task.find_by(name:"test").categories.count to eq 1' do
          expect(Task.find_by(name: 'Test').categories.count).to eq(1)
        end
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
  end

  describe "POST #update" do
    context "given task with no category" do
      before(:each) { @task = Task.create(name:'Test', priority: 1) }
      context "given invalid priority" do
        before(:each) { post :update, { params: { id: @task.id, task: { name: 'Test', priority: 0 }, category: '' } } }
        it { should respond_with :bad_request }
        it { should render_template "edit" }
      end
      context "given one new category" do
        before(:each) do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'asd' } }
        end
        it { should redirect_to tasks_path }
        it 'should result in Category.find_by(name: "asd").tasks.count to eq 1' do
          expect(Category.find_by(name: 'asd').tasks.count).to eq(1)
        end
        it 'should result in Task.find_by(name:"test").categories.count to eq 1' do
          expect(Task.find_by(name: 'Test').categories.count).to eq(1)
        end
      end
      context "given multiple new categories" do
        before(:each) do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'asd,anu' } }
        end
        it { should redirect_to tasks_path }
        it 'should result in Category.find_by(name: "asd").tasks.count to eq 1' do
          expect(Category.find_by(name: 'asd').tasks.count).to eq(1)
        end
        it 'should result in Category.find_by(name: "anu").tasks.count to eq 1' do
          expect(Category.find_by(name: 'asd').tasks.count).to eq(1)
        end
        it 'should result in Task.find_by(name:"test").categories.count to eq 2' do
          expect(Task.find_by(name: 'Test').categories.count).to eq(2)
        end
      end
      context "given addition of one existing category" do
        before(:each) do
          @category = Category.create(name: 'asd')
        end
        it do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'asd' } }
          should redirect_to tasks_path
        end
        it do
          expect {
            post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'asd' } }
          }.to change { @task.categories.count }.by(1)
           .and change { @category.tasks.count }.by(1)
        end
      end
      context "given addition of one new and one existing categories" do
        before(:each) do
          @category = Category.create(name: 'asd')
        end
        it do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'asd,anu' } }
          should redirect_to tasks_path
        end
        it do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'asd,anu' } }
          expect(Category.find_by(name:'anu').tasks.count).to eq(1)
        end
        it do
          expect {
            post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'asd,anu' } }
          }.to change { @category.tasks.count }.by(1)
           .and change { @task.categories.count }.by(2)
        end
      end
    end
    context "given task with one category" do
      before(:each) do
        @task = Task.create(name: 'Test', priority: 1)
        @category = Category.create(name: 'anu')
        Taskcategory.create(task: @task, category: @category)
      end
      context "given invalid priority" do
        before(:each) do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 0 }, category: 'anu' } }
        end
        it { should respond_with :bad_request }
        it { should render_template "edit" }
      end
      context "given one less category" do
        it do
          expect {
            post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: '' } } 
          }.to change { @task.categories.count }.by(-1)
           .and change { @category.tasks.count }.by(-1)
        end
        it do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: '' } } 
          should redirect_to tasks_path
        end
      end
      context "given one new category" do
        it do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'anu,asd' } }
          should redirect_to tasks_path
        end
        it 'should result in Category.find_by(name: "asd").tasks.count to eq 1' do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'anu,asd' } }
          expect(Category.find_by(name: 'asd').tasks.count).to eq(1)
        end
        it do
          expect {
            post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'anu,asd' } }
          }.to change { @task.categories.count }.by(1)
           .and change { @category.tasks.count }.by(0)
        end
      end
      context "given multiple new categories" do
        it do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'anu,abc,asd' } }
          should redirect_to tasks_path
        end
        it 'should result in Category.find_by(name: "asd").tasks.count to eq 1' do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'anu,abc,asd' } }
          expect(Category.find_by(name: 'asd').tasks.count).to eq(1)
        end
        it 'should result in Category.find_by(name: "abc").tasks.count to eq 1' do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'anu,abc,asd' } }
          expect(Category.find_by(name: 'abc').tasks.count).to eq(1)
        end
        it do
          expect {
            post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'anu,abc,asd' } }
          }.to change { @task.categories.count }.by(2)
           .and change { @category.tasks.count }.by(0)
        end
      end
      context "given addition of one existing category" do
        before(:each) do
          @cat2 = Category.create(name: 'asd')
        end
        it do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'anu,asd' } }
          should redirect_to tasks_path
        end
        it do
          expect {
            post :update, { params: { id: @task.id, task: { name: 'Test', priority: 1 }, category: 'anu,asd' } }
          }.to change { @task.categories.count }.by(1)
           .and change { @category.tasks.count }.by(0)
           .and change { @cat2.tasks.count }.by(1)
        end
      end
      context "given addition of one new and one existing categories" do

      end
    end
    context "given task with multiple categories" do
      before(:each) do
        @task = Task.create(name: 'Test', priority: 1)
        @cat1 = Category.create(name: 'anu')
        @cat2 = Category.create(name: 'asd')
        @cat3 = Category.create(name: 'qwe')
        Taskcategory.create(task: @task, category: @cat1)
        Taskcategory.create(task: @task, category: @cat2)
        Taskcategory.create(task: @task, category: @cat3)
      end
      context "given invalid priority" do
        before(:each) do
          post :update, { params: { id: @task.id, task: { name: 'Test', priority: 0 }, category: 'anu,asd,qwe' } }
        end
        it { should respond_with :bad_request }
        it { should render_template "edit" }
      end
      context "given one less category" do
          
      end
      context "given two less category" do

      end
      context "given all categories removed" do

      end
      context "given one new category" do

      end
      context "given multiple new categories" do

      end
      context "given addition of one existing category" do

      end
      context "given addition of one new and one existing categories" do

      end
    end
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
      before { post :done, { params: { id: @task.id, value: true } } }
      it { should respond_with :ok }
      it { expect(response.body).to eq({ success: true, name: @task.name, value: "true" }.to_json) }
    end

    context "given invalid id" do
      it do
        expect {
          post :done, { params: { id: 'unknown', value: true } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
