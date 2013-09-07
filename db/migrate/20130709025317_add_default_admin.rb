class AddDefaultAdmin < ActiveRecord::Migration
  def self.up
    Admin.add_default_admin
  end

  def self.down
  end
end
