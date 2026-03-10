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

ActiveRecord::Schema[8.1].define(version: 2026_03_10_180000) do
  create_table "answer_options", force: :cascade do |t|
    t.text "body"
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.integer "position"
    t.integer "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answer_options_on_question_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "evaluations", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.integer "argumentation"
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "creative_thinking"
    t.integer "execution"
    t.integer "leadership"
    t.integer "quick_learning"
    t.string "recommendation"
    t.integer "score"
    t.integer "team_collaboration"
    t.integer "technical_knowledge"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["admin_id", "user_id"], name: "index_evaluations_on_admin_id_and_user_id", unique: true
    t.index ["admin_id"], name: "index_evaluations_on_admin_id"
    t.index ["user_id"], name: "index_evaluations_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "middle_name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "body"
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_questions_on_category_id"
  end

  create_table "quiz_attempts", force: :cascade do |t|
    t.integer "category_id"
    t.boolean "completed"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["category_id"], name: "index_quiz_attempts_on_category_id"
    t.index ["user_id"], name: "index_quiz_attempts_on_user_id"
  end

  create_table "user_answers", force: :cascade do |t|
    t.boolean "admin_correct"
    t.integer "answer_option_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "question_id", null: false
    t.integer "quiz_attempt_id", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_option_id"], name: "index_user_answers_on_answer_option_id"
    t.index ["question_id"], name: "index_user_answers_on_question_id"
    t.index ["quiz_attempt_id"], name: "index_user_answers_on_quiz_attempt_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "consent_to_personal_data"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.string "state", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["state"], name: "index_users_on_state"
  end

  add_foreign_key "answer_options", "questions"
  add_foreign_key "evaluations", "users"
  add_foreign_key "evaluations", "users", column: "admin_id"
  add_foreign_key "profiles", "users"
  add_foreign_key "questions", "categories"
  add_foreign_key "quiz_attempts", "categories"
  add_foreign_key "quiz_attempts", "users"
  add_foreign_key "user_answers", "answer_options"
  add_foreign_key "user_answers", "questions"
  add_foreign_key "user_answers", "quiz_attempts"
end
