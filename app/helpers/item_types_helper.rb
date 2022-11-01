module ItemTypesHelper
  def get_data_for_item_types_csv
		temp=[]
		@item_types.each do |item_type|
			first = item_type.id
			second = item_type.title
			third = item_type.code
			fourth = item_type.comment
			temp.push([first, second, third, fourth])
		end
		return temp
	end
end
