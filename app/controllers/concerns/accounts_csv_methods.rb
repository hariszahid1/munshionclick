module AccountsCsvMethods
  extend ActiveSupport::Concern

	def get_data_for_accounts_csv
		temp=[]

		@accounts.each do |account|
			first= account.id
			second=account.title

			third=account.bank_name
			fourth=account.amount.to_f.round(2)
			#@account_total += account.amount.to_f 
			if account.amount.to_f < 0
				fifth="Jama"
			elsif account.amount.to_f > 0
				fifth="Benam"
			else
				fifth="Nill"
			end

			temp.push([first,second,third,fourth,fifth])
		end
		temp.push(["total","","",@account_total.first.to_f.round(2),""])
		return temp
	end

end

