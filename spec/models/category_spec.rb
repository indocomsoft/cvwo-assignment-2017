# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  colour     :string
#  user_id    :integer
#
# Indexes
#
#  index_categories_on_user_id  (user_id)
#

require "rails_helper"

RSpec.describe Category, type: :model do
  it { should have_many(:tasks).through(:taskcategories) }
  it { should validate_uniqueness_of(:name).ignoring_case_sensitivity.with_message(" ") }
  it { should validate_presence_of(:name) }
  context "search" do
    before(:each) do
      @user = User.create(email: "test@example.com", password: "123456")
      @cat1 = Category.create(name: "qwerty", user: @user)
      @cat2 = Category.create(name: "asdfghjkl", user: @user)
      @cat3 = Category.create(name: "asdf", user: @user)
    end
    it "finds one result" do
      result = Category.search("sdf")
      expect(result).to eq([@cat2, @cat3])
    end
    it "finds two results" do
      result = Category.search("rty")
      expect(result).to eq([@cat1])
    end
    it "finds result case insensitively" do
      result = Category.search("SdF")
      expect(result).to eq([@cat2, @cat3])
    end
  end
end
