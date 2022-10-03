class AddProductWarrantyListToProduct < ActiveRecord::Migration[5.2]
  def change
    unless column_exists? :products, :warranty_list
      add_column :products, :warranty_list, :text
    end

    Product.reset_column_information

    Product.all.each do |product|
      @warranties_sale=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Sale',product_id: product.id)
      @warranties_purchase=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Purchase',product_id: 	product.id)
      @sale_count=0
      @purchase_count=0
      @sale_array=[]
      @purchase_array=[]
      @warranties_sale.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
      purchase.upcase.split("\r\n").each do |purch|
      @sale_array << purch
      end
      @sale_count=@sale_count+purchase.split("\r\n").count
      end
      @warranties_purchase.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
      purchase.upcase.split("\r\n").each do |purch|
      @purchase_array << purch
      end
      @purchase_count=@purchase_count+purchase.split("\r\n").count
      end
      list=String.new
      (@purchase_array-@sale_array).select{|s| list=s+' '+list}
      product.update(warranty_list: list.gsub(' ',"\r\n")[0...-2])
    end
  end
end
