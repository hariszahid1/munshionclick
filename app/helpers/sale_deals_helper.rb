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
                      payment_type: d.purchase_sale_items&.first&.size_7,
                      profit: d.purchase_sale_items&.first&.size_6,
                      down_payment: d.purchase_sale_items&.first&.size_5,
                      received: d.purchase_sale_items&.first&.size_4,
                      balance: d.purchase_sale_items&.first&.size_3,
                      total: d.purchase_sale_items&.first&.size_2,
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
			temp.push([first, second, third, four, fifth, six, seven, eight, nine, ten, eleven, tweleve, thirteen,
                  fourteen, fifteen
                ])
		end
		return temp
	end
end
