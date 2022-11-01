module DepartmentsHelper
  def get_data_for_departments_csv
		temp=[]
		@departments.each do |department|
			first=department.id
			second=department.title
			third=department.comment
			fourth=department.code
			temp.push([first, second, third, fourth])
		end
		return temp
	end
end
