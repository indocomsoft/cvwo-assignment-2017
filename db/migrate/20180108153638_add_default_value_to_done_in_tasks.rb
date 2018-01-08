class AddDefaultValueToDoneInTasks < ActiveRecord::Migration[5.1]
  def change
    change_column_default :tasks, :done, from: nil, to: false
    Task.where(done: nil).update_all(done: false)
    change_column_null :tasks, :done, false
  end
end
