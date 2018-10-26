class CreateLastFmTrackInfo < ActiveRecord::Migration[5.2]
  def change
    create_table :last_fm_track_info do |t|
      t.integer :duration
      t.string :mbid, unique: true
      t.timestamps nulls: false
    end
  end
end
