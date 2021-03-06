# frozen_string_literal: true

require "rails_helper"

RSpec.describe TasksController, type: :controller do
  before(:each) do
    @user = User.create(email: "test@example.com", password: "123456")
    request.session[:user_id] = @user.id
  end

  describe "GET #index" do
    context "logged in" do
      before(:each) { get :index }
      it { should respond_with :ok }
      it { should render_template "index" }
    end
    context "search" do
      before(:each) do
        @task1 = @user.tasks.create(name: "qwertyuiop", priority: 1)
        @task2 = @user.tasks.create(name: "asdfghjkl", priority: 2)
        @task3 = @user.tasks.create(name: "asdf", priority: 3)
        get :index, params: { search: "sdf" }
      end
      it { should render_template "index" }
      it { should respond_with :ok }
      it { expect(assigns(:tasks)).to eq([@task2, @task3]) }
    end
    context "unauthenticated" do
      before(:each) do
        request.session.delete(:user_id)
        get :index
      end
      it { should redirect_to login_path }
    end
  end

  describe "GET #show" do
    before(:each) do
      @task = @user.tasks.create(name: "Test1", priority: 1)
      @task2 = @user.tasks.create(name: "Test2", priority: 7)
    end
    context "tasks/all" do
      before(:each) { get :show, params: { id: "all" }, format: :json }
      it { should respond_with :ok }
      it { expect(response.body).to eq(@user.tasks.all.map { |e| e.name }.to_a.to_json) }
    end

    context "else" do
      before(:each) { get :show, params: { id: @task.id }, format: :json }
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
    it do
      should permit(:name, :priority).
        for(:create, verb: :post, params: { task: { name: "Test", priority: 1 }, category: "" }).
        on(:task)
    end

    context "given valid task" do
      context "given no category" do
        before(:each) { post :create, params: { task: { name: "Test", priority: 1 }, category: "" } }
        it { should redirect_to tasks_path }
      end

      context "given one new category" do
        before(:each) { post :create, params: { task: { name: "Test", priority: 1 }, category: "asd" } }
        it { should redirect_to tasks_path }
        it 'should result in @user.categories.find_by(name: "asd").tasks.count to eq 1' do
          expect(@user.categories.find_by(name: "asd").tasks.count).to eq(1)
        end
        it 'should result in @user.tasks.find_by(name:"test").categories.count to eq 1' do
          expect(@user.tasks.find_by(name: "Test").categories.count).to eq(1)
        end
      end

      context "given multiple new categories" do
        before(:each) { post :create, params: { task: { name: "Test", priority: 1 }, category: "asd,anu" } }
        it { should redirect_to tasks_path }
        it 'should result in @user.categories.find_by(name: "asd").tasks.count to eq 1' do
          expect(@user.categories.find_by(name: "asd").tasks.count).to eq(1)
        end
        it 'should result in @user.categories.find_by(name: "anu").tasks.count to eq 1' do
          expect(@user.categories.find_by(name: "anu").tasks.count).to eq(1)
        end
        it 'should result in @user.tasks.find_by(name:"test").categories.count to eq 2' do
          expect(@user.tasks.find_by(name: "Test").categories.count).to eq(2)
        end
      end

      context "given a mix of new and existing, unassociated categories" do
        before(:each) do
          @category = @user.categories.create(name: "anu")
          post :create, params: { task: { name: "Test", priority: 1 }, category: "asd,anu" }
        end
        it { should redirect_to tasks_path }
        it 'should result in @user.categories.find_by(name: "asd").tasks.count to eq 1' do
          expect(@user.categories.find_by(name: "asd").tasks.count).to eq(1)
        end
        it 'should result in @user.categories.find_by(name: "anu").tasks.count to eq 1' do
          expect(@user.categories.find_by(name: "anu").tasks.count).to eq(1)
        end
        it 'should result in @user.tasks.find_by(name:"test").categories.count to eq 2' do
          expect(@user.tasks.find_by(name: "Test").categories.count).to eq(2)
        end
      end

      context "given a mix of new and existing, already associated categories" do
        before(:each) do
          @category = @user.categories.create(name: "anu")
          @task = @user.tasks.create(name: "ExistingTask", priority: 1)
          Taskcategory.create(task: @task, category: @category)
          post :create, params: { task: { name: "Test", priority: 1 }, category: "asd,anu" }
        end
        it { should redirect_to tasks_path }
        it 'should result in @user.categories.find_by(name: "asd").tasks.count to eq 1' do
          expect(@user.categories.find_by(name: "asd").tasks.count).to eq(1)
        end
        it 'should result in @user.categories.find_by(name: "anu").tasks.count to eq 2' do
          expect(@user.categories.find_by(name: "anu").tasks.count).to eq(2)
        end
        it "should result in existing task to still be associated to existing category" do
          expect(@task.categories.first.name).to eq("anu")
        end
        it 'should result in @user.tasks.find_by(name:"test").categories.count to eq 2' do
          expect(@user.tasks.find_by(name: "Test").categories.count).to eq(2)
        end
      end

      context "given existing category" do
        before(:each) do
          @category = @user.categories.create(name: "asd")
          post :create, params: { task: { name: "Test", priority: 1 }, category: "asd" }
        end
        it { should redirect_to tasks_path }
        it 'should result in @user.categories.find_by(name: "asd").tasks.count to eq 1' do
          expect(@user.categories.find_by(name: "asd").tasks.count).to eq(1)
        end
        it 'should result in @user.tasks.find_by(name:"test").categories.count to eq 1' do
          expect(@user.tasks.find_by(name: "Test").categories.count).to eq(1)
        end
      end
    end

    context "given invalid task" do
      before(:each) do
        post :create, params: { task: { name: "Test", priority: 0 }, category: "" }
      end
      it { should respond_with :bad_request }
      it { should render_template "new" }
    end
  end

  describe "GET #edit" do
    before(:each) { @task = @user.tasks.create(name: "Test", priority: 1) }

    context "given valid id" do
      before(:each) { get :edit, params: { id: @task.id } }
      it { should respond_with :ok }
      it { should render_template "edit" }
    end

    context "given invalid id" do
      it do
        expect {
          get :edit, params: { id: "unknown" }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST #update" do
    context "given task with no category" do
      before(:each) { @task = @user.tasks.create(name: "Test", priority: 1) }
      context "given invalid priority" do
        before(:each) { post :update, params: { id: @task.id, task: { name: "Test", priority: 0 }, category: "" } }
        it { should respond_with :bad_request }
        it { should render_template "edit" }
      end
      context "given one new category" do
        before(:each) do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "asd" }
        end
        it { should redirect_to tasks_path }
        it 'should result in @user.categories.find_by(name: "asd").tasks.count to eq 1' do
          expect(@user.categories.find_by(name: "asd").tasks.count).to eq(1)
        end
        it 'should result in @user.tasks.find_by(name:"test").categories.count to eq 1' do
          expect(@user.tasks.find_by(name: "Test").categories.count).to eq(1)
        end
      end
      context "given multiple new categories" do
        before(:each) do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "asd,anu" }
        end
        it { should redirect_to tasks_path }
        it 'should result in @user.categories.find_by(name: "asd").tasks.count to eq 1' do
          expect(@user.categories.find_by(name: "asd").tasks.count).to eq(1)
        end
        it 'should result in @user.categories.find_by(name: "anu").tasks.count to eq 1' do
          expect(@user.categories.find_by(name: "asd").tasks.count).to eq(1)
        end
        it 'should result in @user.tasks.find_by(name:"test").categories.count to eq 2' do
          expect(@user.tasks.find_by(name: "Test").categories.count).to eq(2)
        end
      end
      context "given addition of one existing category" do
        before(:each) do
          @category = @user.categories.create(name: "asd")
        end
        it do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "asd" }
          should redirect_to tasks_path
        end
        it do
          expect {
            post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "asd" }
          }.to change { @task.categories.count }.by(1)
           .and change { @category.tasks.count }.by(1)
        end
      end
      context "given addition of one new and one existing categories" do
        before(:each) do
          @category = @user.categories.create(name: "asd")
        end
        it do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "asd,anu" }
          should redirect_to tasks_path
        end
        it do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "asd,anu" }
          expect(@user.categories.find_by(name: "anu").tasks.count).to eq(1)
        end
        it do
          expect {
            post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "asd,anu" }
          }.to change { @category.tasks.count }.by(1)
           .and change { @task.categories.count }.by(2)
        end
      end
    end
    context "given task with one category" do
      before(:each) do
        @task = @user.tasks.create(name: "Test", priority: 1)
        @category = @user.categories.create(name: "anu")
        Taskcategory.create(task: @task, category: @category)
      end
      context "given invalid priority" do
        before(:each) do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 0 }, category: "anu" }
        end
        it { should respond_with :bad_request }
        it { should render_template "edit" }
      end
      context "given one less category" do
        it do
          expect {
            post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "" }
          }.to change { @task.categories.count }.by(-1)
           .and change { @category.tasks.count }.by(-1)
        end
        it do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "" }
          should redirect_to tasks_path
        end
      end
      context "given one new category" do
        it do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "anu,asd" }
          should redirect_to tasks_path
        end
        it 'should result in @user.categories.find_by(name: "asd").tasks.count to eq 1' do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "anu,asd" }
          expect(@user.categories.find_by(name: "asd").tasks.count).to eq(1)
        end
        it do
          expect {
            post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "anu,asd" }
          }.to change { @task.categories.count }.by(1)
           .and change { @category.tasks.count }.by(0)
        end
      end
      context "given multiple new categories" do
        it do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "anu,abc,asd" }
          should redirect_to tasks_path
        end
        it 'should result in @user.categories.find_by(name: "asd").tasks.count to eq 1' do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "anu,abc,asd" }
          expect(@user.categories.find_by(name: "asd").tasks.count).to eq(1)
        end
        it 'should result in @user.categories.find_by(name: "abc").tasks.count to eq 1' do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "anu,abc,asd" }
          expect(@user.categories.find_by(name: "abc").tasks.count).to eq(1)
        end
        it do
          expect {
            post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "anu,abc,asd" }
          }.to change { @task.categories.count }.by(2)
           .and change { @category.tasks.count }.by(0)
        end
      end
      context "given addition of one existing category" do
        before(:each) do
          @cat2 = @user.categories.create(name: "asd")
        end
        it do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "anu,asd" }
          should redirect_to tasks_path
        end
        it do
          expect {
            post :update, params: { id: @task.id, task: { name: "Test", priority: 1 }, category: "anu,asd" }
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
        @task = @user.tasks.create(name: "Test", priority: 1)
        @cat1 = @user.categories.create(name: "anu")
        @cat2 = @user.categories.create(name: "asd")
        @cat3 = @user.categories.create(name: "qwe")
        Taskcategory.create(task: @task, category: @cat1)
        Taskcategory.create(task: @task, category: @cat2)
        Taskcategory.create(task: @task, category: @cat3)
      end
      context "given invalid priority" do
        before(:each) do
          post :update, params: { id: @task.id, task: { name: "Test", priority: 0 }, category: "anu,asd,qwe" }
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
    before(:each) { @task = @user.tasks.create(name: "Test", priority: 1) }
    it do
      expect {
        delete :destroy, params: { id: @task.id }
      }.to change { @user.tasks.count }.by(-1)
    end
    it do
      delete :destroy, params: { id: @task.id }
      should redirect_to(tasks_path)
    end
  end

  describe "POST #done" do
    before(:each) { @task = @user.tasks.create(name: "Test", priority: 1) }
    context "given valid id" do
      before { post :done, params: { id: @task.id, value: true } }
      it { should respond_with :ok }
      it { expect(response.body).to eq({ success: true, name: @task.name, value: "true" }.to_json) }
    end

    context "given invalid id" do
      it do
        expect {
          post :done, params: { id: "unknown", value: true }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#sortable" do
    context "no param" do
      it "works for priority" do
        expect(subject.send(:sortable, "priority", "#")).to eq(["#<i class=\"fa fa-sort-asc\"></i>".html_safe, sort: "priority", direction: "desc"])
      end
      it "works for name" do
        expect(subject.send(:sortable, "name", "Tasks")).to eq(["Tasks".html_safe, sort: "name", direction: "asc"])
      end
      it "works for due_date" do
        expect(subject.send(:sortable, "due_date")).to eq(["Due Date".html_safe, sort: "due_date", direction: "asc"])
      end
      it "works for done" do
        expect(subject.send(:sortable, "done")).to eq(["Done".html_safe, sort: "done", direction: "asc"])
      end
    end
    context "by name desc" do
      before(:each) do
        allow(subject).to receive(:params).and_return(sort: "name", direction: "desc")
      end
      it "works for priority" do
        expect(subject.send(:sortable, "priority", "#")).to eq(["#".html_safe, sort: "priority", direction: "asc"])
      end
      it "works for name" do
        expect(subject.send(:sortable, "name", "Tasks")).to eq(["Tasks<i class=\"fa fa-sort-desc\"></i>".html_safe, sort: "name", direction: "asc"])
      end
      it "works for due_date" do
        expect(subject.send(:sortable, "due_date")).to eq(["Due Date".html_safe, sort: "due_date", direction: "asc"])
      end
      it "works for done" do
        expect(subject.send(:sortable, "done")).to eq(["Done".html_safe, sort: "done", direction: "asc"])
      end
    end
  end

end
