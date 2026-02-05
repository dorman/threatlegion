# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_02_05_235119) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cached_malicious_ips", force: :cascade do |t|
    t.string "ip_address"
    t.string "country_code"
    t.integer "abuse_confidence_score"
    t.datetime "last_reported_at"
    t.string "source"
    t.json "metadata"
    t.datetime "last_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "indicators", force: :cascade do |t|
    t.string "indicator_type"
    t.string "value"
    t.bigint "threat_id"
    t.datetime "first_seen"
    t.datetime "last_seen"
    t.integer "confidence"
    t.text "tags"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["threat_id"], name: "index_indicators_on_threat_id"
  end

  create_table "mitre_attacks", force: :cascade do |t|
    t.string "tactic"
    t.string "technique"
    t.string "technique_id"
    t.text "description"
    t.bigint "threat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["threat_id"], name: "index_mitre_attacks_on_threat_id"
  end

  create_table "threat_scores", force: :cascade do |t|
    t.integer "score"
    t.string "threat_level"
    t.json "components"
    t.datetime "recorded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "threats", force: :cascade do |t|
    t.string "name"
    t.string "threat_type"
    t.string "severity"
    t.text "description"
    t.string "status"
    t.datetime "first_seen"
    t.datetime "last_seen"
    t.integer "confidence_score"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_threats_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "role"
    t.string "api_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vulnerabilities", force: :cascade do |t|
    t.string "cve_id"
    t.decimal "cvss_score"
    t.text "description"
    t.datetime "published_date"
    t.text "affected_products"
    t.bigint "threat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["threat_id"], name: "index_vulnerabilities_on_threat_id"
  end

  create_table "workflow_connections", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.bigint "source_node_id", null: false
    t.bigint "target_node_id", null: false
    t.string "source_output"
    t.string "target_input"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_node_id"], name: "index_workflow_connections_on_source_node_id"
    t.index ["target_node_id"], name: "index_workflow_connections_on_target_node_id"
    t.index ["workflow_id"], name: "index_workflow_connections_on_workflow_id"
  end

  create_table "workflow_executions", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.bigint "user_id", null: false
    t.string "status", default: "pending"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text "result_data"
    t.text "error_message"
    t.integer "records_processed", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_workflow_executions_on_user_id"
    t.index ["workflow_id"], name: "index_workflow_executions_on_workflow_id"
  end

  create_table "workflow_nodes", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.string "node_type", null: false
    t.string "service_name"
    t.string "label"
    t.decimal "position_x", precision: 10, scale: 2, default: "0.0"
    t.decimal "position_y", precision: 10, scale: 2, default: "0.0"
    t.text "config"
    t.string "node_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_workflow_nodes_on_node_id"
    t.index ["workflow_id"], name: "index_workflow_nodes_on_workflow_id"
  end

  create_table "workflows", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "user_id", null: false
    t.string "status", default: "draft"
    t.text "config"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_workflows_on_user_id"
  end

  add_foreign_key "indicators", "threats"
  add_foreign_key "mitre_attacks", "threats"
  add_foreign_key "threats", "users"
  add_foreign_key "vulnerabilities", "threats"
  add_foreign_key "workflow_connections", "workflow_nodes", column: "source_node_id"
  add_foreign_key "workflow_connections", "workflow_nodes", column: "target_node_id"
  add_foreign_key "workflow_connections", "workflows"
  add_foreign_key "workflow_executions", "users"
  add_foreign_key "workflow_executions", "workflows"
  add_foreign_key "workflow_nodes", "workflows"
  add_foreign_key "workflows", "users"
end
