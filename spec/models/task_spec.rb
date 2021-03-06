# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  due_date    :date
#  priority    :integer
#  done        :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#
# Indexes
#
#  index_tasks_on_user_id  (user_id)
#

require "rails_helper"

RSpec.describe Task, type: :model do
  it { should have_many(:categories).through(:taskcategories) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }
  it { should validate_numericality_of(:priority).
        with_message("must be between 1 and 10 inclusive.").
        is_less_than(11).
        is_greater_than(0) }
  context "search" do
    before(:each) do
      @user = User.create(email: "test@example.com", password: "123456")
      @task1 = Task.create(name: "qwerty", priority: 1, user: @user)
      @task2 = Task.create(name: "asdfghjkl", priority: 2, user: @user)
      @task3 = Task.create(name: "asdf", priority: 3, user: @user)
    end
    it "finds one result" do
      result = Task.search("sdf")
      expect(result).to eq([@task2, @task3])
    end
    it "finds two results" do
      result = Task.search("rty")
      expect(result).to eq([@task1])
    end
    it "finds result case insensitively" do
      result = Task.search("SdF")
      expect(result).to eq([@task2, @task3])
    end
  end
end
