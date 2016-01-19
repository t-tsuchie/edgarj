class RenameEdgarToEdgarj < ActiveRecord::Migration
  def up
    rename_table :edgar_sssns,              :edgarj_sssns
    rename_table :edgar_page_infos,         :edgarj_page_infos
    rename_table :edgar_user_groups,        :edgarj_user_groups
    rename_table :edgar_user_group_users,   :edgarj_user_group_users
    rename_table :edgar_model_permissions,  :edgarj_model_permissions
  end

  def down
    rename_table :edgarj_sssns,             :edgar_sssns
    rename_table :edgarj_page_infos,        :edgar_page_infos
    rename_table :edgarj_user_groups,       :edgar_user_groups
    rename_table :edgarj_user_group_users,  :edgar_user_group_users
    rename_table :edgarj_model_permissions, :edgar_model_permissions
  end
end
