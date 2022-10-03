class AddReferencesPolymorphicToExpenseEntry < ActiveRecord::Migration[5.2]
  def change
    add_reference :expense_entries, :expenseable, polymorphic: true, index: true
  end
end
