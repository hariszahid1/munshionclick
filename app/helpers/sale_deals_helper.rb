module SaleDealsHelper
  def sorted_data
    @sorted_data = []
    @sale_deals.each do |d|
      @sorted_data << {
                      id: d.id,
                      deal_date: d.purchase_sale_items&.first&.expiry_date&.strftime('%d-%m-%Y'),
                      name: d.sys_user&.name,
                      contact: d.sys_user.occupation,
                      project: d.sys_user&.cms_data&.try(:[], 'project_name')&.titleize,
                      plot_type: d.sys_user&.cms_data&.try(:[], 'category')&.titleize,
                      plot_size: d.sys_user&.ntn,
                      form_no: d.purchase_sale_items&.first&.size_11,
                      ms: d.purchase_sale_items&.first&.size_2,
                      purchase_from: d.destination,
                      share: d.l_c,
                      type: d.transaction_type
                      }
    end
  end

  def get_data_for_sale_deals_csv
		temp = []
    @sale_deals.each do |d|
      data = [
        d.purchase_sale_items&.first&.expiry_date&.strftime('%d-%m-%Y'),
        d.sys_user&.name,
        d.sys_user&.occupation,
        d.sys_user&.cms_data&.fetch('category', ''),
        d.sys_user&.ntn,
        d.sys_user&.cms_data&.fetch('project_name', ''),
        d.purchase_sale_items&.first&.size_11,
        d.purchase_sale_items&.first&.size_2,
        d.destination,
        d.l_c,
        d.transaction_type
      ]
      temp.push(data)
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
