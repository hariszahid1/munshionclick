class CreateSalaries < ActiveRecord::Migration[5.0]
  def change
    create_table :salaries do |t|
      t.integer :paid_salary
      t.integer :advance, default: 0
      t.integer :leaves_in_month, default: 0
      t.references :staff, foreign_key: true
      t.integer :paid_to
      t.integer :payment_type, default: "Salary"
      t.integer :advance_amount, default: 0
      t.integer :advance_due_till_this_transaction, default: 0
      t.timestamps
    end
  end
end
