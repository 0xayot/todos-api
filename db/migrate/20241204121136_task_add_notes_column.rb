class TaskAddNotesColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :note, :text
    add_column :tasks, :user_id, :integer

    add_foreign_key :tasks, :users, column: :user_id
  end
end

