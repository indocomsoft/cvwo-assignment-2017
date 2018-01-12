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
#

require "rails_helper"

RSpec.describe Task, type: :model do
  it { should have_many(:categories).through(:taskcategories) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_numericality_of(:priority).
        with_message("must be between 1 and 10 inclusive.").
        is_less_than(11).
        is_greater_than(0) }
end
