class CreateEdgarUserGroups < ActiveRecord::Migration
  def change
    create_table :edgar_user_groups do |t|
      t.integer   :kind
      t.string    :name
      t.integer   :parent_id
      t.integer   :lft
      t.integer   :rgt

      t.timestamps
    end

    add_index :edgar_user_groups, :kind
    add_index :edgar_user_groups, :parent_id
    add_index :edgar_user_groups, :lft
    add_index :edgar_user_groups, :rgt
  end
end
