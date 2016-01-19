class CreateEdgarSssns < ActiveRecord::Migration
  def change
    create_table :edgar_sssns do |t|
      t.string :session_id, null: false
      t.text    :data
      t.integer :user_id

      t.timestamps
    end

    add_index :edgar_sssns, :session_id
    add_index :edgar_sssns, :updated_at
  end
end
