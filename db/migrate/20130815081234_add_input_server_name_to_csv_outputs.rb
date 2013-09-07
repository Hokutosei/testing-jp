class AddInputServerNameToCsvOutputs < ActiveRecord::Migration
  def self.up
    add_column :csv_outputs, :input_server_name, :string
    #add default input server name can not use
    Admin.add_default_input_server_name
  end

  def self.down
    remove_column :csv_outputs, :input_server_name
  end
end
