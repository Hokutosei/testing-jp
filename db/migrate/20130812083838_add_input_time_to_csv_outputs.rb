class AddInputTimeToCsvOutputs < ActiveRecord::Migration
  def self.up
    #input time
    add_column :csv_outputs, :input_time, :datetime
  end

  def self.down
    remove_column :csv_outputs, :input_time
  end
end
