class AddDueDateToDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :property_plans, :due_date, :datetime
    add_column :property_plans, :due_status, :integer
    add_column :property_installments, :due_date, :datetime
    add_column :property_installments, :due_status, :integer
  end
end
