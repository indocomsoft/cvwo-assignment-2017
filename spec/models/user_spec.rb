# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  username   :string           not null
#  name       :string
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { User.new(username: "test", email: "anu@anu.com") }
  it { should validate_uniqueness_of(:username) }
  it { should validate_presence_of(:email) }
end
