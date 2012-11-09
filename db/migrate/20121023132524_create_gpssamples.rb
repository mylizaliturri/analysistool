class CreateGpssamples < ActiveRecord::Migration
  def change
    create_table :gpssamples do |t|
      t.integer :userid
      t.integer :latitude
      t.integer :longitude
      t.integer :time
      t.string :archivo

      t.timestamps
    end
  end
end
