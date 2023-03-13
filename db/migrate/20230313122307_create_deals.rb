class CreateDeals < ActiveRecord::Migration[6.1]
  def change
    create_table :deals do |t|
      t.text :deal_detail
      t.integer :comission
      t.integer :file_share
      t.integer :share
      t.integer :agent_earning
      t.references :staff

      t.timestamps
    end
  end
end
