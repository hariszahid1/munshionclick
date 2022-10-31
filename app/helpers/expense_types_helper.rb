module ExpenseTypesHelper
    def get_data_for_expense_types_csv
		temp=[]
		@expense_types.each do |expense_type|
			first=expense_type.id
			second=expense_type.title
			third=expense_type.comment
			temp.push([first, second, third])
		end
		return temp
	end
end
