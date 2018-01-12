# frozen_string_literal: true

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
# Indexes
#
#  index_taskcategories_on_category_id  (category_id)
#  index_taskcategories_on_task_id      (task_id)
#

class Taskcategory < ApplicationRecord
  belongs_to :task
  belongs_to :category
end
