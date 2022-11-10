module AccountsHelper
  def get_data_for_accounts_csv
		temp=[]
		@accounts.each do |d|
			first = d.id
      second = d.title
      third = d.bank_name
      forth = d.amount.to_f.round(2)
      fifth = d.amount.to_i.zero? ? 'Nill' : d.amount.to_f.negative? ? 'Jama' : 'Benam'
			temp.push([first, second, third, forth, fifth])
		end
    temp.push([nil, nil, 'Total:', @account_total.first.to_f.round(2), nil])

		return temp
	end
end
