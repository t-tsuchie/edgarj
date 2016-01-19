class CreateEdgarUserGroupUsers < ActiveRecord::Migration
  def change
    create_table :edgar_user_group_users do |t|
      t.integer   :user_group_id
      t.integer   :user_id

      t.timestamps
    end
  end
end
