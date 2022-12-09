# frozen_string_literal: true

# CSV Methods
module ExpenseCsvMethods
  extend ActiveSupport::Concern

	def expense_csv
    @time = Time.zone.now
		CSV.generate do |csv|
      csv.add_row ['-----------------------']
			csv.add_row ["Total Expenses => #{@expenses.sum(:expense).round(2)}"]
			csv.add_row ['-----------------------']

			csv.add_row ['Date', 'Type Wise','Amount','Paid By','Comment']
      csv.add_row ['-----------------------']	

			@expenses.each_with_index do |item,i|
        

        item.expense_entries.joins(:expense_type).group(:expense_type).sum(:amount).each do |expense|
          temp_1st_column_value=""
        if item.created_at.strftime("%d%b%y")!=item.updated_at.strftime("%d%b%y")
          temp_1st_column_value=item.created_at.present? ? item.created_at.strftime("%d%b%y at %H:%M%p") : ''  |  item.updated_at.present? ? item.updated_at.strftime("%d%b%y at %H:%M%p") : '' 
        else
          temp_1st_column_value=item.created_at.present? ? item.created_at.strftime("%A,  %d-%b-%y at %H:%M%p") : '' 
        end

        csv.add_row [ 
            temp_1st_column_value,
            Account.where(id: item.expense_entries.distinct.pluck(:account_id)).pluck(:title),
						item.expense,
						Account.where(id: item.expense_entries.distinct.pluck(:account_id)).pluck(:title),
						item.expense_entries.distinct.pluck(:comment),
            item.comment
					]
        end
      end
      csv.add_row ["","Total",@expenses.sum(:expense).round(2)]
		end
	end

end

