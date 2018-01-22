# frozen_string_literal: true

class AddUserToTasksAndCategories < ActiveRecord::Migration[5.1]
  def change
    change_table :tasks do |t|
      t.belongs_to :user
    end
    change_table :categories do |t|
      t.belongs_to :user
    end
  end
end
