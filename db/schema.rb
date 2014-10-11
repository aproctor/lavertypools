# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141011153927) do

  create_table "leagues", force: true do |t|
    t.string   "name"
    t.integer  "sport_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leagues", ["sport_id"], name: "index_leagues_on_sport_id", using: :btree

  create_table "matches", force: true do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.float    "spread"
    t.integer  "home_score"
    t.integer  "away_score"
    t.integer  "league_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matches", ["league_id"], name: "index_matches_on_league_id", using: :btree

  create_table "picks", force: true do |t|
    t.integer  "player_id"
    t.integer  "match_id"
    t.integer  "pool_id"
    t.integer  "winner"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "picks", ["match_id"], name: "index_picks_on_match_id", using: :btree
  add_index "picks", ["player_id"], name: "index_picks_on_player_id", using: :btree
  add_index "picks", ["pool_id"], name: "index_picks_on_pool_id", using: :btree

  create_table "players", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players_pools", force: true do |t|
    t.integer "player_id", null: false
    t.integer "pool_id",   null: false
  end

  create_table "pools", force: true do |t|
    t.string   "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "league_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pools", ["league_id"], name: "index_pools_on_league_id", using: :btree

  create_table "sports", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: true do |t|
    t.string   "reference"
    t.string   "location"
    t.integer  "league_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "logo_offset_x"
    t.integer  "logo_offset_y"
  end

  add_index "teams", ["league_id"], name: "index_teams_on_league_id", using: :btree

end
