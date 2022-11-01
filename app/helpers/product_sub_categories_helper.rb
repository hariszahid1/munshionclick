module ProductSubCategoriesHelper
    def get_data_for_product_sub_categories_csv
		temp=[]
		@product_sub_categories.each do |product_sub_category|
			first=product_sub_category.id
			second=product_sub_category.title
			third=product_sub_category.comment
            fourth=product_sub_category.product_category.title
            fifth=product_sub_category.code
			temp.push([first,second,third,fourth,fifth])
		end
		return temp
	end
end
