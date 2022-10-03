class CreateStaffDeals < ActiveRecord::Migration[5.2]
  def change
    create_table :staff_deals do |t|
      t.references :staff
      t.references :product
      t.decimal :cost
      t.text :comment

      t.timestamps
    end
  end
end
