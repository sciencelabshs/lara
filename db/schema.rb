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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20180703131647) do

  create_table "admin_events", :force => true do |t|
    t.string   "kind"
    t.text     "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "approved_scripts", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "label"
  end

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "index"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "authentications", ["uid", "provider"], :name => "index_authentications_on_uid_and_provider", :unique => true
  add_index "authentications", ["user_id", "provider"], :name => "index_authentications_on_user_id_and_provider", :unique => true

  create_table "c_rater_feedback_items", :force => true do |t|
    t.text     "answer_text"
    t.integer  "answer_id"
    t.string   "answer_type"
    t.string   "item_id"
    t.string   "status"
    t.integer  "score"
    t.text     "feedback_text"
    t.text     "response_info"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "feedback_submission_id"
    t.string   "feedback_submission_type"
  end

  add_index "c_rater_feedback_items", ["answer_id", "answer_type"], :name => "c_rat_feed_it_answer_idx"
  add_index "c_rater_feedback_items", ["feedback_submission_id", "feedback_submission_type"], :name => "c_rater_feed_item_submission_idx"

  create_table "c_rater_feedback_submissions", :force => true do |t|
    t.integer  "usefulness_score"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "interactive_page_id"
    t.integer  "run_id"
    t.integer  "collaboration_run_id"
    t.integer  "base_submission_id"
  end

  add_index "c_rater_feedback_submissions", ["base_submission_id"], :name => "feedback_submissions_base_sub_id_idx"
  add_index "c_rater_feedback_submissions", ["interactive_page_id", "run_id", "created_at"], :name => "c_rater_fed_submission_page_run_created_idx"

  create_table "c_rater_item_settings", :force => true do |t|
    t.string   "item_id"
    t.integer  "score_mapping_id"
    t.integer  "provider_id"
    t.string   "provider_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "c_rater_item_settings", ["provider_id", "provider_type"], :name => "c_rat_set_prov_idx"
  add_index "c_rater_item_settings", ["score_mapping_id"], :name => "index_c_rater_settings_on_score_mapping_id"

  create_table "c_rater_score_mappings", :force => true do |t|
    t.text     "mapping"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "description"
    t.integer  "user_id"
    t.integer  "changed_by_id"
  end

  create_table "collaboration_runs", :force => true do |t|
    t.integer  "user_id"
    t.string   "collaborators_data_url"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "collaboration_runs", ["collaborators_data_url"], :name => "collaboration_runs_endpoint_idx"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "embeddable_external_scripts", :force => true do |t|
    t.integer  "approved_script_id"
    t.text     "configuration"
    t.text     "description"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "embeddable_feedback_items", :force => true do |t|
    t.integer  "answer_id"
    t.string   "answer_type"
    t.integer  "score"
    t.text     "feedback_text"
    t.text     "answer_text"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "feedback_submission_id"
    t.string   "feedback_submission_type"
  end

  add_index "embeddable_feedback_items", ["answer_id", "answer_type"], :name => "index_embeddable_feedback_items_on_answer_id_and_answer_type"
  add_index "embeddable_feedback_items", ["feedback_submission_id", "feedback_submission_type"], :name => "e_feed_item_submission_idx"

  create_table "embeddable_image_question_answers", :force => true do |t|
    t.integer  "run_id"
    t.text     "answer_text"
    t.string   "image_url"
    t.integer  "image_question_id"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.text     "annotation",          :limit => 2147483647
    t.string   "annotated_image_url"
    t.boolean  "is_dirty",                                  :default => false
    t.boolean  "is_final",                                  :default => false
  end

  add_index "embeddable_image_question_answers", ["image_question_id"], :name => "index_on_image_question_id"
  add_index "embeddable_image_question_answers", ["run_id", "image_question_id"], :name => "index_on_run_and_question"
  add_index "embeddable_image_question_answers", ["run_id"], :name => "index_on_run_id"

  create_table "embeddable_image_questions", :force => true do |t|
    t.string   "name"
    t.text     "prompt"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.string   "bg_source",                        :default => "Shutterbug"
    t.string   "bg_url"
    t.text     "drawing_prompt"
    t.boolean  "is_prediction",                    :default => false
    t.boolean  "give_prediction_feedback",         :default => false
    t.text     "prediction_feedback"
    t.boolean  "is_hidden",                        :default => false
    t.text     "hint"
    t.boolean  "is_full_width",                    :default => false
    t.integer  "interactive_id"
    t.string   "interactive_type"
    t.boolean  "show_in_featured_question_report", :default => true
  end

  create_table "embeddable_labbook_answers", :force => true do |t|
    t.integer  "run_id"
    t.integer  "labbook_id"
    t.boolean  "is_dirty",   :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "embeddable_labbook_answers", ["labbook_id"], :name => "index_embeddable_labbook_answers_on_labbook_id"
  add_index "embeddable_labbook_answers", ["run_id"], :name => "index_embeddable_labbook_answers_on_run_id"

  create_table "embeddable_labbooks", :force => true do |t|
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.integer  "action_type",                      :default => 0,     :null => false
    t.string   "name"
    t.text     "prompt"
    t.string   "custom_action_label"
    t.boolean  "is_hidden",                        :default => false
    t.integer  "interactive_id"
    t.string   "interactive_type"
    t.text     "hint"
    t.boolean  "is_full_width",                    :default => false
    t.boolean  "show_in_featured_question_report", :default => true
  end

  add_index "embeddable_labbooks", ["interactive_id"], :name => "labbook_interactive_i_idx"
  add_index "embeddable_labbooks", ["interactive_type"], :name => "labbook_interactive_t_idx"

  create_table "embeddable_multiple_choice_answers", :force => true do |t|
    t.integer  "run_id"
    t.integer  "multiple_choice_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "is_dirty",           :default => false
    t.boolean  "is_final",           :default => false
  end

  add_index "embeddable_multiple_choice_answers", ["multiple_choice_id"], :name => "index_embeddable_multiple_choice_answers_on_multiple_choice_id"
  add_index "embeddable_multiple_choice_answers", ["run_id"], :name => "index_embeddable_multiple_choice_answers_on_run_id"

  create_table "embeddable_multiple_choice_choices", :force => true do |t|
    t.integer  "multiple_choice_id"
    t.text     "choice"
    t.boolean  "is_correct"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.text     "prompt"
  end

  add_index "embeddable_multiple_choice_choices", ["multiple_choice_id"], :name => "index_embeddable_multiple_choice_choices_on_multiple_choice_id"

  create_table "embeddable_multiple_choices", :force => true do |t|
    t.string   "name"
    t.text     "prompt"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.boolean  "custom",                           :default => false
    t.boolean  "enable_check_answer",              :default => true
    t.boolean  "multi_answer",                     :default => false
    t.boolean  "show_as_menu",                     :default => false
    t.boolean  "is_prediction",                    :default => false
    t.boolean  "give_prediction_feedback",         :default => false
    t.text     "prediction_feedback"
    t.string   "layout",                           :default => "vertical"
    t.boolean  "is_hidden",                        :default => false
    t.text     "hint"
    t.boolean  "is_full_width",                    :default => false
    t.boolean  "show_in_featured_question_report", :default => true
  end

  create_table "embeddable_open_response_answers", :force => true do |t|
    t.text     "answer_text"
    t.integer  "run_id"
    t.integer  "open_response_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "is_dirty",         :default => false
    t.boolean  "is_final",         :default => false
  end

  add_index "embeddable_open_response_answers", ["open_response_id"], :name => "index_embeddable_open_response_answers_on_open_response_id"
  add_index "embeddable_open_response_answers", ["run_id", "open_response_id"], :name => "index_open_response_answers_on_run_and_question"
  add_index "embeddable_open_response_answers", ["run_id"], :name => "index_embeddable_open_response_answers_on_run_id"

  create_table "embeddable_open_responses", :force => true do |t|
    t.string   "name"
    t.text     "prompt"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.boolean  "is_prediction",                    :default => false
    t.boolean  "give_prediction_feedback",         :default => false
    t.text     "prediction_feedback"
    t.string   "default_text"
    t.boolean  "is_hidden",                        :default => false
    t.text     "hint"
    t.boolean  "is_full_width",                    :default => false
    t.boolean  "show_in_featured_question_report", :default => true
  end

  create_table "embeddable_xhtmls", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "is_hidden",     :default => false
    t.boolean  "is_full_width", :default => false
  end

  create_table "global_interactive_states", :force => true do |t|
    t.integer  "run_id"
    t.text     "raw_data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "global_interactive_states", ["run_id"], :name => "index_global_interactive_states_on_run_id"

  create_table "image_interactives", :force => true do |t|
    t.string   "url"
    t.text     "caption"
    t.text     "credit"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "show_lightbox", :default => true
    t.string   "credit_url"
    t.boolean  "is_hidden",     :default => false
    t.boolean  "is_full_width", :default => true
  end

  create_table "imports", :force => true do |t|
    t.string   "export_site"
    t.integer  "user_id"
    t.integer  "import_item_id"
    t.string   "import_item_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "interactive_items", :force => true do |t|
    t.integer  "interactive_page_id"
    t.integer  "interactive_id"
    t.string   "interactive_type"
    t.integer  "position"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "interactive_items", ["interactive_id", "interactive_type"], :name => "interactive_items_interactive_idx"
  add_index "interactive_items", ["interactive_page_id", "position"], :name => "interactive_items_by_page_idx"

  create_table "interactive_pages", :force => true do |t|
    t.string   "name"
    t.integer  "lightweight_activity_id"
    t.integer  "position"
    t.text     "text"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.text     "sidebar"
    t.boolean  "show_introduction",       :default => false
    t.boolean  "show_sidebar",            :default => false
    t.boolean  "show_interactive",        :default => false
    t.boolean  "show_info_assessment",    :default => false
    t.string   "workflow_state"
    t.string   "layout",                  :default => "l-6040"
    t.string   "embeddable_display_mode", :default => "stacked"
    t.string   "sidebar_title",           :default => "Did you know?"
    t.text     "additional_sections"
    t.boolean  "is_hidden",               :default => false,           :null => false
    t.boolean  "is_completion",           :default => false
  end

  add_index "interactive_pages", ["lightweight_activity_id", "position"], :name => "interactive_pages_by_activity_idx"

  create_table "interactive_run_states", :force => true do |t|
    t.integer  "interactive_id"
    t.string   "interactive_type"
    t.integer  "run_id"
    t.text     "raw_data"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.text     "learner_url"
    t.boolean  "is_dirty",         :default => false
    t.string   "key"
  end

  add_index "interactive_run_states", ["key"], :name => "interactive_run_states_key_idx"
  add_index "interactive_run_states", ["run_id"], :name => "interactive_run_states_run_id_idx"

  create_table "lightweight_activities", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "publication_status",                   :default => "private"
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.integer  "offerings_count"
    t.text     "related"
    t.text     "description"
    t.integer  "changed_by_id"
    t.boolean  "is_official",                          :default => false
    t.integer  "time_to_complete"
    t.boolean  "is_locked",                            :default => false
    t.text     "notes"
    t.string   "thumbnail_url"
    t.integer  "theme_id"
    t.integer  "project_id"
    t.integer  "portal_run_count",                     :default => 0
    t.integer  "layout",                               :default => 0
    t.integer  "editor_mode",                          :default => 0
    t.string   "publication_hash",       :limit => 40
    t.string   "imported_activity_url"
    t.integer  "copied_from_id"
    t.text     "external_report_url"
    t.boolean  "student_report_enabled",               :default => true
  end

  add_index "lightweight_activities", ["changed_by_id"], :name => "index_lightweight_activities_on_changed_by_id"
  add_index "lightweight_activities", ["project_id"], :name => "index_lightweight_activities_on_project_id"
  add_index "lightweight_activities", ["publication_status"], :name => "lightweight_activities_publication_status_idx"
  add_index "lightweight_activities", ["theme_id"], :name => "index_lightweight_activities_on_theme_id"
  add_index "lightweight_activities", ["updated_at"], :name => "lightweight_activities_updated_at_idx"
  add_index "lightweight_activities", ["user_id"], :name => "lightweight_activities_user_idx"

  create_table "lightweight_activities_sequences", :force => true do |t|
    t.integer  "lightweight_activity_id", :default => 1, :null => false
    t.integer  "sequence_id",             :default => 1, :null => false
    t.integer  "position",                :default => 1
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "lightweight_activities_sequences", ["lightweight_activity_id"], :name => "index_activities_sequence_join_by_activity"
  add_index "lightweight_activities_sequences", ["sequence_id"], :name => "index_activities_sequence_join_by_sequence"

  create_table "mc_answer_choices", :id => false, :force => true do |t|
    t.integer "answer_id"
    t.integer "choice_id"
  end

  add_index "mc_answer_choices", ["answer_id", "choice_id"], :name => "index_mc_answer_choices_on_answer_id_and_choice_id"
  add_index "mc_answer_choices", ["choice_id", "answer_id"], :name => "index_mc_answer_choices_on_choice_id_and_answer_id"

  create_table "mw_interactives", :force => true do |t|
    t.string   "name"
    t.text     "url"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.integer  "native_width"
    t.integer  "native_height"
    t.boolean  "enable_learner_state",             :default => false
    t.boolean  "has_report_url",                   :default => false
    t.boolean  "click_to_play"
    t.string   "image_url"
    t.boolean  "is_hidden",                        :default => false
    t.integer  "linked_interactive_id"
    t.boolean  "full_window",                      :default => false
    t.text     "authored_state"
    t.string   "model_library_url"
    t.boolean  "no_snapshots",                     :default => false
    t.string   "click_to_play_prompt"
    t.boolean  "show_delete_data_button",          :default => true
    t.boolean  "is_full_width",                    :default => true
    t.boolean  "show_in_featured_question_report", :default => true
  end

  add_index "mw_interactives", ["linked_interactive_id"], :name => "index_mw_interactives_on_linked_interactive_id"

  create_table "page_items", :force => true do |t|
    t.integer  "interactive_page_id"
    t.integer  "embeddable_id"
    t.string   "embeddable_type"
    t.integer  "position"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "section"
  end

  add_index "page_items", ["embeddable_id", "embeddable_type"], :name => "index_page_items_on_embeddable_id_and_embeddable_type"
  add_index "page_items", ["interactive_page_id"], :name => "index_page_items_on_interactive_page_id"

  create_table "pending_portal_publications", :force => true do |t|
    t.integer  "portal_publication_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "pending_portal_publications", ["portal_publication_id"], :name => "unique_publications_per_portal", :unique => true

  create_table "portal_publications", :force => true do |t|
    t.string   "portal_url"
    t.text     "response"
    t.boolean  "success"
    t.integer  "publishable_id"
    t.string   "publishable_type"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "publication_hash", :limit => 40
    t.integer  "publication_time"
    t.text     "sent_data"
  end

  add_index "portal_publications", ["publishable_id", "publishable_type"], :name => "index_portal_publications_on_publishable_id_and_publishable_type"

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.string   "logo"
    t.string   "url"
    t.text     "footer"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "theme_id"
    t.text     "about"
    t.text     "help"
  end

  add_index "projects", ["theme_id"], :name => "index_projects_on_theme_id"

  create_table "question_trackers", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "master_question_id"
    t.string  "master_question_type"
    t.integer "user_id"
  end

  create_table "runs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "run_count"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "key"
    t.integer  "activity_id"
    t.string   "remote_id"
    t.integer  "page_id"
    t.string   "remote_endpoint"
    t.integer  "sequence_id"
    t.integer  "sequence_run_id"
    t.boolean  "is_dirty",             :default => false
    t.integer  "collaboration_run_id"
    t.text     "class_info_url"
  end

  add_index "runs", ["activity_id"], :name => "index_runs_on_activity_id"
  add_index "runs", ["collaboration_run_id"], :name => "runs_collaboration_idx"
  add_index "runs", ["key"], :name => "index_runs_on_key"
  add_index "runs", ["remote_endpoint"], :name => "index_runs_on_remote_endpoint"
  add_index "runs", ["sequence_id"], :name => "index_runs_on_sequence_id"
  add_index "runs", ["sequence_run_id"], :name => "index_runs_on_sequence_run_id"
  add_index "runs", ["user_id", "activity_id"], :name => "index_runs_on_user_id_and_activity_id"
  add_index "runs", ["user_id", "remote_id", "remote_endpoint"], :name => "runs_user_remote_endpt_idx"
  add_index "runs", ["user_id"], :name => "index_runs_on_user_id"

  create_table "sequence_runs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "sequence_id"
    t.string   "remote_id"
    t.string   "remote_endpoint"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "sequence_runs", ["sequence_id"], :name => "index_sequence_runs_on_sequence_id"
  add_index "sequence_runs", ["user_id"], :name => "index_sequence_runs_on_user_id"

  create_table "sequences", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.integer  "user_id"
    t.integer  "theme_id"
    t.integer  "project_id"
    t.text     "logo"
    t.string   "publication_status",                  :default => "private"
    t.boolean  "is_official",                         :default => false
    t.string   "display_title"
    t.string   "thumbnail_url"
    t.text     "abstract"
    t.string   "publication_hash",      :limit => 40
    t.string   "imported_activity_url"
    t.text     "external_report_url"
  end

  add_index "sequences", ["project_id"], :name => "index_sequences_on_project_id"
  add_index "sequences", ["theme_id"], :name => "index_sequences_on_theme_id"
  add_index "sequences", ["updated_at"], :name => "sequences_updated_at_idx"
  add_index "sequences", ["user_id"], :name => "index_sequences_on_user_id"

  create_table "themes", :force => true do |t|
    t.string   "name"
    t.string   "css_file"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tracked_questions", :force => true do |t|
    t.integer "question_tracker_id"
    t.integer "question_id"
    t.string  "question_type"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "is_admin",               :default => false
    t.boolean  "is_author",              :default => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "video_interactives", :force => true do |t|
    t.string   "poster_url"
    t.text     "caption"
    t.text     "credit"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "width",         :default => 556,   :null => false
    t.integer  "height",        :default => 240,   :null => false
    t.boolean  "is_hidden",     :default => false
    t.boolean  "is_full_width", :default => true
  end

  create_table "video_sources", :force => true do |t|
    t.string   "url",                  :null => false
    t.string   "format",               :null => false
    t.integer  "video_interactive_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "video_sources", ["video_interactive_id"], :name => "index_video_sources_on_video_interactive_id"

end
