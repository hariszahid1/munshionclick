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
end
