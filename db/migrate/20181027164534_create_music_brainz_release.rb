# frozen_string_literal: true

class CreateMusicBrainzRelease < ActiveRecord::Migration[5.2]
  def change
    create_table :music_brainz_releases do |t|
      t.string :artist_album_hash
      t.jsonb :recordings
    end
  end
end
