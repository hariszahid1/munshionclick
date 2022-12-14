class CreateLoans < ActiveRecord::Migration[6.1]
  def change
    create_table :loans do |t|
      t.decimal :debit
      t.decimal :credit
      t.text :comment
      t.references :account
      t.timestamps
    end
  end
end
