class AddGstHstVatPstQstVatToProductAndSystem < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :gst, :float, default: 0 # nakasi stock
    add_column :products, :vat, :float, default: 0 # nakasi stock
    add_column :products, :hst, :float, default: 0 # nakasi stock
    add_column :products, :pst, :float, default: 0 # nakasi stock
    add_column :products, :qst, :float, default: 0 # nakasi stock
  end
end
