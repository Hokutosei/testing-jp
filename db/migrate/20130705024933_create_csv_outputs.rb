class CreateCsvOutputs < ActiveRecord::Migration
  def self.up
    create_table :csv_outputs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :csv_outputs
  end
end
