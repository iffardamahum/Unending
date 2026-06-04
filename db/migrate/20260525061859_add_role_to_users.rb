class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, default: "member", null: false

   # Migrate existing admin users
   User.where(admin: true).update_all(role: "master_admin")
  end
end
