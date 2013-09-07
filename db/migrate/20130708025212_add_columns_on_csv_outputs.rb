class AddColumnsOnCsvOutputs < ActiveRecord::Migration
  def self.up
    add_column :csv_outputs, :server_name, :string
    add_column :csv_outputs, :school_id, :integer
    add_column :csv_outputs, :course_ids, :text
    add_column :csv_outputs, :user_ids, :text
    add_column :csv_outputs, :output_flag, :boolean, :default => false
    add_column :csv_outputs, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :csv_outputs, :server_name
    remove_column :csv_outputs, :school_id
    remove_column :csv_outputs, :course_ids
    remove_column :csv_outputs, :user_ids
    remove_column :csv_outputs, :output_flag
    remove_column :csv_outputs, :deleted
  end
end
