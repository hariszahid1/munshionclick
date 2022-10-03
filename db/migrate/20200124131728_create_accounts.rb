class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :title
      t.string :bank_name
      t.string :iban_number
      t.integer :amount

      t.timestamps
    end
  end
end
