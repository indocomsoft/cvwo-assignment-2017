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
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Task < ApplicationRecord
  has_and_belongs_to_many :categories
  validates :priority, numericality: { only_integer: true, greater_than: 0, less_than: 11, message: "must be between 1 and 10 inclusive." }
end
