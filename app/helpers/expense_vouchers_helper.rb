module ExpenseVouchersHelper
  def sorted_data
    @sorted_data = []
    @q.result.each do |d|
      @sorted_data << {
                      id: d.id,
                      type_wise: d.expense_entry_vouchers.joins(:expense_type).group(:expense_type).sum(:amount).map do |d|
                        d.first.title.to_s + ':' + d.last.to_s
                      end,
                      expense: d.amount.to_f.round(2),
                      expense_remark: d.comment,
                      comment: d.expense_entry_vouchers.distinct.pluck(:comment),
                      date: d.created_at.strftime('%d-%b-%y')
                       }
    end
  end

  def get_data_for_expense_vouchers_csv
		temp=[]
		@q.result.each do |d|
			first = d.id
      second = d.expense_entry_vouchers.joins(:expense_type).group(:expense_type).sum(:amount).map{ |d| d.first.title.to_s + ':' + d.last.to_s }
      third = d.amount.to_f.round(2)
      forth = d.comment
      fifth = d.expense_entry_vouchers.distinct.pluck(:comment)
      sixth = d.created_at.strftime('%d-%b-%y')
			temp.push([first, second, third, forth, fifth, sixth])
		end
		return temp
	end
end
