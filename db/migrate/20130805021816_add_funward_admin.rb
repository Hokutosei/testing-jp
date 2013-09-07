class AddFunwardAdmin < ActiveRecord::Migration
  def self.up
    Admin.add_funward_admin
    Admin.change_admin_password("admin", "db_move2013")
  end

  def self.down
  end
end
