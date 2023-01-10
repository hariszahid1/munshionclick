module SaleDealsHelper
  def sorted_data
    @sorted_data = []
    @sale_deals.each do |d|
      @sorted_data << {
                      id: d.id,
                      agent: @all_agents&.to_h.invert[d.sys_user&.credit_status].to_s,
                      name: d.sys_user&.name,
                      contact: d.sys_user.occupation,
                      quota: d.purchase_sale_items&.first&.size_13,
                      transaction: d.purchase_sale_items&.first&.size_12,
                      project: d.sys_user&.cms_data&.try(:[], 'project_name')&.titleize,
                      plot_type: d.sys_user&.cms_data&.try(:[], 'category')&.titleize,
                      form_no: d.purchase_sale_items&.first&.size_11,
                      plot_size: d.sys_user&.ntn,
                      quantity: d.purchase_sale_items&.first&.size_10,
                      category: d.purchase_sale_items&.first&.size_9,
                      price: d.purchase_sale_items&.first&.size_8,
                      deal_date: d.purchase_sale_items&.first&.expiry_date&.strftime('%d-%m-%Y'),
                      payment_status: d.purchase_sale_items&.first&.size_7,
                      deal: d.purchase_sale_items&.first&.size_4,
                      profit: d.purchase_sale_items&.first&.size_6,
                      down_payment: d.purchase_sale_items&.first&.size_5,
                      received: d.amount,
                      balance: d.remaining_balance,
                      total: d.total_bill,
                      trx: d.purchase_sale_items&.first&.size_1,
                      internal: d.purchase_sale_items&.first&.comment,
                      external: d.comment
                      }
    end
  end

  def get_data_for_sale_deals_csv
		temp=[]
		@sale_deals.each do |d|
      first = @all_agents&.to_h.invert[d.sys_user&.credit_status].to_s
      second = d.sys_user&.name
      third =  d.sys_user.occupation
      four = d.purchase_sale_items&.first&.size_13
      fifth = d.purchase_sale_items&.first&.size_12
      six = d.sys_user&.cms_data&.try(:[], 'project_name')&.titleize
      seven = d.sys_user&.cms_data&.try(:[], 'category')&.titleize
      eight = d.purchase_sale_items&.first&.size_11
      nine =  d.sys_user&.ntn
      ten = d.purchase_sale_items&.first&.size_10
      eleven  = d.purchase_sale_items&.first&.size_9
      tweleve = d.purchase_sale_items&.first&.size_8
      thirteen = d.purchase_sale_items&.first&.expiry_date&.strftime('%d-%m-%Y')
      fourteen = d.purchase_sale_items&.first&.size_7
      fifteen = d.purchase_sale_items&.first&.size_1
      sixteen = d.purchase_sale_items&.first&.size_4
			temp.push([first, second, third, four, fifth, six, seven, eight, nine, ten, eleven, tweleve, thirteen,
                  fourteen, fifteen, sixteen
                ])
		end
		return temp
	end

  def modify_update_salary_details
    staff = @sale_deal.staff
    staff.wage_debit = ((@sale_deal.carriage + @sale_deal.loading) - @before_update_carriage_loading + staff.wage_debit)
    staff.balance = ((@sale_deal.carriage + @sale_deal.loading) - @before_update_carriage_loading + staff.balance)
    staff.save!
    if @sale_deal.salary_details.present?
      @sale_deal.salary_details.first.update(staff_id: @sale_deal.staff_id, amount: @sale_deal.carriage, comment:
                                            'Carriage', total_balance: staff.balance - @sale_deal.loading,
                                             created_at: @sale_deal.created_at)
      @sale_deal.salary_details.last.update(staff_id: @sale_deal.staff_id, amount: @sale_deal.loading, comment:
                                          'Loading', total_balance: staff.balance, created_at: @sale_deal.created_at)
    else
      @sale_deal.salary_details.create(staff_id: @sale_deal.staff_id, amount: @sale_deal.carriage, comment: 'Carriage',
                                       total_balance: staff.balance - @sale_deal.loading, created_at: @sale_deal.created_at)
      @sale_deal.salary_details.create(staff_id: @sale_deal.staff_id, amount: @sale_deal.loading, comment: 'Loading',
                                       total_balance: staff.balance, created_at: @sale_deal.created_at)
    end
  end

  def modify_salary_details
    staff = @sale_deal.staff
    staff.wage_debit += @sale_deal.carriage + @sale_deal.loading
    staff.balance += @sale_deal.carriage + @sale_deal.loading
    staff.save!
    @sale_deal.salary_details.create(staff_id: @sale_deal.staff_id, amount: @sale_deal.carriage,
                                     comment: 'Carriage', total_balance: staff.balance - @sale_deal.loading,
                                     created_at: @sale_deal.created_at)
    @sale_deal.salary_details.create(staff_id: @sale_deal.staff_id, amount: @sale_deal.loading,
                                     comment: 'Loading', total_balance: staff.balance,
                                     created_at: @sale_deal.created_at)
  end
end
