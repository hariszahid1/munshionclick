class AddRowProductToProduct < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :raw_product
  end
end
 
