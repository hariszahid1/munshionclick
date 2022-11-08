module CitiesHelper
	def get_data_for_cities_csv
		temp=[]
		@cities.each do |city|
			first=city.id
			second=city.title
			third=city.comment
			temp.push([first, second, third])
		end
		return temp
	end

	def get_data_for_user_groups_csv
		temp=[]
		@user_groups.each do |user_group|
			first = user_group.id
			second = user_group.title
			third = user_group.comment
			temp.push([first, second, third])
		end
		return temp
	end
end
