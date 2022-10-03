class CreateSalaryDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :salary_details do |t|
      t.references :staff
      t.float :wage_rate
      t.float :quantity
      t.float :amount
      t.text :remarks
      t.text :comment

      t.timestamps
    end
  end
end
