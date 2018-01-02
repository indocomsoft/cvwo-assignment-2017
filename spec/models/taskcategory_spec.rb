# == Schema Information
#
# Table name: taskcategories
#
#  id          :integer          not null, primary key
#  task_id     :integer          not null
#  category_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Taskcategory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
