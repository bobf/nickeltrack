class CreateLastFmTrackPlay < ActiveRecord::Migration[5.2]
  def change
    create_table :last_fm_track_plays do |t|
      t.string :artist
      t.string :album
      t.string :name
      t.integer :duration
      t.integer :timestamp, unique: true
      t.timestamps nulls: false
    end
  end
end
