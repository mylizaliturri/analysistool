class UpdateGpssamples2 < ActiveRecord::Migration
  def up
    change_column :Gpssamples, :latitude, :float
  end

  def down
  end
end
