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

class Category < ApplicationRecord
  has_many :taskcategories
  has_many :tasks, through: :taskcategories
  validates :name, uniqueness: true

  def assign_tasks(input_tasks)
    existing = tasks.all.map { |t| t.name }
    input = input_tasks.split(",")
    to_add = input - existing
    to_rm = existing - input

    to_add.each do |t|
      task = Task.find_or_create_by(name: t)
      Taskcategory.create(task: task, category: self)
    end

    to_rm.each do |t|
      task = Task.find_by(name: t)
      Taskcategory.find_by(task: task, category: self).destroy
    end
  end
end
