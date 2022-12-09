module PurchaseSaleDetailsCsvMethods
  extend ActiveSupport::Concern

	def get_data_for_purchase_csv
		temp=[]
		@total=0
		@products_count.each_with_index do |item,i|
			first=item.first
			second=item.last.to_f.round(2)
			@total+=item.last.to_f.round(2)
			third=@products_sale_price[item.first].to_f.round(2)
			fourth=@products_sale[item.first].to_f.round(2)
			temp.push([first,second,third,fourth])
		end
		temp.push(["total",@Total,"",@products_sale_total.to_f.round(2)])
		temp.push(["-","-","","-"])
		temp.push(["Carriage","","",@product_carriage.to_i])
		temp.push(["Loading","","",@product_loading.to_i])
		temp.push(["Total","","",(@product_loading.to_f+@product_carriage.to_f+@products_sale_total.to_f).round(2)])
		return temp
	end

end

