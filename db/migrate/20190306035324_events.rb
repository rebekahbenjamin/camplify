class Events < ActiveRecord::Migration[5.2]
  def self.up
    create_table :events do |t|
       t.column :week_number, :integer
       t.column :start_date, :timestamp, :null => false
       t.column :end_date, :timestamp, :null => false
       t.column :year, :string
    end
  end

  def self.down
    drop_table :events
  end
end
