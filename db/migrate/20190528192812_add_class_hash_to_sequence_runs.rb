class AddClassHashToSequenceRuns < ActiveRecord::Migration
  def change
    add_column :sequence_runs, :class_hash, :string
    add_column :sequence_runs, :class_info_url, :string
  end
end
