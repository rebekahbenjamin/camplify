class AddIndexToEvents < ActiveRecord::Migration[5.2]
  def change
    add_index :events, :start_date, unique: true
    add_index :events, :end_date, unique: true
  end
end
