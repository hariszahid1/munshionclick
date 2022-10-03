class AddConfirmationToPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :confirmable, :integer
    add_column :payments, :confirmed_by, :integer
    add_column :payments, :confirmed_at, :datetime
  end
end
