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
#  user_id     :integer
#
# Indexes
#
#  index_tasks_on_user_id  (user_id)
#

class Task < ApplicationRecord
  has_many :taskcategories
  has_many :categories, through: :taskcategories
  belongs_to :user
  validates :name, uniqueness: true, presence: true
  validates :priority, numericality: { only_integer: true, greater_than: 0, less_than: 11, message: "must be between 1 and 10 inclusive." }

  def assign_categories(input_categories, user)
    existing = categories.all.map { |c| c.name }
    input = input_categories.split(",")
    to_add = input - existing
    to_rm = existing - input

    to_add.each do |c|
      category = user.categories.find_or_create_by!(name: c)
      Taskcategory.create!(task: self, category: category)
    end

    to_rm.each do |c|
      category = user.categories.find_by(name: c)
      Taskcategory.find_by(task: self, category: category).destroy
    end
  end
end
