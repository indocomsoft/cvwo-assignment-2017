class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :description
      t.date :due_date
      t.integer :priority
      t.boolean :done

      t.timestamps
    end
  end
end
