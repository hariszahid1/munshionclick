class CreateLedgerBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :ledger_books do |t|
      t.references :sys_user, foreign_key: true
      t.decimal :debit
      t.decimal :credit
      t.decimal :balance
      t.string :comment
      t.timestamps
    end
  end
end
