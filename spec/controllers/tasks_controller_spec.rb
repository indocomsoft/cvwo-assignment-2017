require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  it do
    params = { task: { name: 'Test', priority: 1 }, category: '' }
    should permit(:name, :priority).for(:create, verb: :post, params: params).on(:task)
  end

  describe "GET #index" do
    before { get :index }
    it { should respond_with :ok }
  end
end
