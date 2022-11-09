module SysUsersHelper
  def get_data_for_sys_users_csv
		temp=[]
		@sys_users.each do |su|
			first = su.id
			second = su.code
      third = su.name
      forth = su.user_group
      fifth = su.status
      sixth = su.occupation
      seventh = su.opening_balance.to_f.round(2)
      eightth = su.balance.to_f.round(2)
      ninth = su.balance.to_i.zero? ? 'Nill' : su.balance.to_f.positive? ? 'Jama' : 'Benam'
      tenth = su.contact&.city&.title

			temp.push([first, second, third, forth, fifth, sixth, seventh, eightth, ninth, tenth])
		end
    temp.push([nil, nil, nil, nil, nil, nil, 'Total:', @sys_users.sum(:balance).to_f.round(2), nil, nil])
		return temp
	end

  def get_data_for_sys_users_custom_clear_csv
		temp=[]
		@sys_users.each do |su|
			first = su.id
      second = su.code
      third = su.name
      forth = su.user_type&.title
      fifth = su.user_group
      sixth = su.status
      seventh = su.occupation
      eightth = su.credit_status.to_f.round(2)
      ninth = su.credit_limit.to_f.round(2)
      tenth = su.balance.to_f.round(2)

			temp.push([first, second, third, forth, fifth, sixth, seventh, eightth, ninth, tenth])
		end
    temp.push([nil, nil, nil, nil, nil, nil, nil, nil, 'Total:', @sys_users.sum(:balance).to_f.round(2)])
		return temp
	end

end
