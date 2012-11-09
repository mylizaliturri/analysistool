class CreateActssamples < ActiveRecord::Migration
  def change
    create_table :actssamples do |t|
      t.integer :time
      t.integer :count
      t.integer :userid
      t.timestamps
    end
  end
end
