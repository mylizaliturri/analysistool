class UpdateGpssamples < ActiveRecord::Migration
  def up
    change_column :Gpssamples, :latitude, :float
    change_column :Gpssamples, :longitude, :float
  end

  def down
  end
end
