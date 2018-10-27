# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_27_164534) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "last_fm_track_plays", force: :cascade do |t|
    t.string "artist"
    t.string "album"
    t.string "name"
    t.integer "duration"
    t.integer "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["timestamp"], name: "index_last_fm_track_plays_on_timestamp", unique: true
  end

  create_table "listens", force: :cascade do |t|
    t.string "artist"
    t.string "album"
    t.string "name"
    t.integer "timestamp"
    t.string "mbid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "music_brainz_releases", force: :cascade do |t|
    t.string "artist_album_hash"
    t.jsonb "recordings"
  end

  create_table "tracks", force: :cascade do |t|
    t.integer "duration"
    t.string "mbid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
