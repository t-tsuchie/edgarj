class CreateEdgarModelPermissions < ActiveRecord::Migration
  def change
    create_table :edgar_model_permissions do |t|
      t.integer  "user_group_id"
      t.string   "name"
      t.integer  "flags"
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
      t.string   "model"
    end

    add_index :edgar_model_permissions, :model
  end
end
