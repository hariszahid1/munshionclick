class CreatePropertyInstallments < ActiveRecord::Migration[5.2]
  def change
    create_table :property_installments do |t|
      t.references :property_plan, foreign_key: true
      t.integer :installment_no
      t.decimal :installment_price, precision: 15, scale: 2

      t.timestamps
    end
  end
end
