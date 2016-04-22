class AddTrackedQuestion < ActiveRecord::Migration
  def change
    create_table :tracked_questions do |t|
      t.references :question_tracker, index: true
      t.references :question, polymorphic: true, index: true
    end
  end
end
