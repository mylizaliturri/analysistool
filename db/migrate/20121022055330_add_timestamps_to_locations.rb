class AddTimestampsToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :timestamp, :integer
  end
end
