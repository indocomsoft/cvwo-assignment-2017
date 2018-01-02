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

class Taskcategory < ApplicationRecord
  belongs_to :task
  belongs_to :category
end
