module CountriesHelper
  def get_data_for_countries_csv
		temp=[]
		@countries.each do |city|
			first=city.id
			second=city.title
			third=city.comment
			temp.push([first, second, third])
		end
		return temp
	end
end
