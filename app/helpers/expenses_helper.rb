module ExpensesHelper
  def get_data_for_expenses_csv
		temp=[]
		@expenses.each do |d|
			first = d.id
      second = d.expense_entries.joins(:expense_type).group(:expense_type).sum(:amount).map{ |d| d.first.title.to_s + ':' + d.last.to_s }
      third = d.expense.to_f.round(2)
      forth = Account.where(id: d.expense_entries.distinct.pluck(:account_id)).pluck(:title).to_s
      fifth = d.comment
      sixth = d.expense_entries.distinct.pluck(:comment)
      seventh = d.created_at.strftime('%d%b%y') != d.updated_at.strftime('%d%b%y') ? d.updated_at.strftime("%d%b%y at %H:%M%p") : d.created_at.strftime("%d%b%y at %H:%M%p")
			temp.push([first, second, third, forth, fifth, sixth, seventh])
		end
    temp.push([nil, 'Total:', @expenses.sum(:expense).to_f.round(2), nil, nil, nil, nil])

		return temp
	end
end
