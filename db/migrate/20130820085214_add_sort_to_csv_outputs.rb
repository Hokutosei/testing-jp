class AddSortToCsvOutputs < ActiveRecord::Migration
  def self.up
    add_column :csv_outputs, :sort, :string
  end

  def self.down
    remove_column :csv_outputs, :sort
  end
end
