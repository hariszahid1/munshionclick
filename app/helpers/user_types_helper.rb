module UserTypesHelper
  def get_data_for_user_types_csv
		temp=[]
		@user_types.each do |user_type|
			first = user_type.id
			second = user_type.title
			third = user_type.code
      fourth = user_type.discount_by_percentage
      fifth = user_type.discount_by_amount
      sixth = user_type.comment
			temp.push([first, second, third, fourth, fifth, sixth])
		end
		return temp
	end
end
