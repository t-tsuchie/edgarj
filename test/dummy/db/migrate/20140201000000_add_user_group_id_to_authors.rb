class AddUserGroupIdToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :user_group_id, :integer
  end
end
