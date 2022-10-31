module ProductCategoriesHelper
    def get_data_for_product_categories_csv
		temp=[]
		@product_categories.each do |product_categories|
			first=product_categories.id
			second=product_categories.title
			third=product_categories.comment
            fourth=product_categories.code
			temp.push([first,second,third,fourth])
		end
		return temp
	end
end
