class CreateCsvInputs < ActiveRecord::Migration
  def self.up
    create_table :csv_inputs do |t|
      t.column :project_name, :string
      t.column :server_name, :string
      t.column :school_id, :integer
      t.column :course_ids, :text
      t.column :user_ids, :text
      t.column :input_flag, :boolean, :default => false
      t.column :deleted, :boolean, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :csv_inputs
  end
end
