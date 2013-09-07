class AddInputFlagOnCsvOutputs < ActiveRecord::Migration
  def self.up
    add_column :csv_outputs, :project_name, :string
    add_column :csv_outputs, :input_flag, :boolean, :default => false
  end

  def self.down
    remove_column :csv_outputs, :project_name
    remove_column :csv_outputs, :input_flag
  end
end
