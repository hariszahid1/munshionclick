class AddColumnToGate < ActiveRecord::Migration[5.2]
  def change
    add_column :gates, :purchase_from, :datetime
    add_column :gates, :purchase_to, :datetime
    add_column :gates, :sale_from, :datetime
    add_column :gates, :sale_to, :datetime
  end
end
