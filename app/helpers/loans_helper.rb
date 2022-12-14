module LoansHelper
	def get_data_for_loans_csv
		temp=[]
		@loans.each do |loan|
			first = loan.debit
			second = loan.credit
			third = loan.account&.title
			fourth = loan.comment
			fifth = loan.created_at.strftime('%d-%m-%y')

			temp.push([first, second, third, fourth, fifth])
		end
		return temp
	end

  def sorted_data
    @sorted_data = []
    @loans.each do |d|
      @sorted_data << {
                        debit: d.debit,
												credit: d.credit,
												paid_by: d.account&.title,
												comment: d.comment,
												date: d.created_at.strftime("%d-%m-%y")
                       }
    end
  end

end