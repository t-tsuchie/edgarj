class CreateEdgarPageInfos < ActiveRecord::Migration
  def change
    create_table :edgar_page_infos do |t|
      t.integer   :sssn_id
      t.string    :view
      t.string    :order_by
      t.string    :dir
      t.integer   :page
      t.integer   :lines
      t.text      :record_data

      t.timestamps
    end
  end
end
