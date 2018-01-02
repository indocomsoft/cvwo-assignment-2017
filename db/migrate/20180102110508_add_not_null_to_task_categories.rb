class AddNotNullToTaskCategories < ActiveRecord::Migration[5.1]
  def change
    change_column_null :taskcategories, :task_id, false
    change_column_null :taskcategories, :category_id, false
  end
end
