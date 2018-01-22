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
#

require "rails_helper"

RSpec.describe Category, type: :model do
  it { should have_many(:tasks).through(:taskcategories) }
  it { should validate_uniqueness_of(:name).ignoring_case_sensitivity.with_message(" ") }
  context "search" do
    before(:each) do
      @cat1 = Category.create(name: "qwerty")
      @cat2 = Category.create(name: "asdfghjkl")
      @cat3 = Category.create(name: "asdf")
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
