# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Category, type: :model do
  it { should have_many(:tasks).through(:taskcategories) }
  it { should validate_uniqueness_of(:name).ignoring_case_sensitivity.with_message(" ") }
end
