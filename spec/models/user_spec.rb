# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string
#  email           :string           not null
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email)
#

require "rails_helper"

RSpec.describe User, type: :model do
  subject { User.new(email: "anu@anu.com", password: "abcdef") }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_presence_of(:email) }
  it "rejects invalid email" do
    user = User.create(email: "Test", password: "123456")
    expect(user.errors[:email]).to eq(["is invalid"])
  end
  it { should validate_length_of(:password).is_at_least(6) }
  it "saves email as lowercase" do
    user = User.create(email: "AnU@abc.com", password: "123456")
    expect(user.email).to eq("anu@abc.com")
  end
end
