# frozen_string_literal: true

# CMS Helper
module InwardsHelper

	def sorted_data
    @sorted_data = []
    @pdf_orders.each do |o|
      @sorted_data << {
		                id: o.id, 
                        type: o.transaction_type,
												name: o.sys_user&.name,
												status: o.status,
												amount: o.amount,
												items: o.order_items.map { |i|
												{ product: i.product&.title,
													marka: i.marka,
													builty_no: i.builty_no,
													vehicle_no: i.vehicle_no,
													challan_no: i.challan_no,
													quantity: i.quantity
												}
												}
                       }
    end
	@sorted_data = @sorted_data.sort_by { |ord| ord[:id] }.reverse if (@sorted_data.present? && params[:pdf].eql?("Total Purchase PDF A8 Desc"))
  end

  def sorted_show_data
	order_total = @order.order_items&.sum(:quantity)
    @sorted_data = []
      @sorted_data << {
		                id: @order.id,
                        type: @order.transaction_type,
						total_quantity: order_total,
						date: @order.created_at&.strftime("%d-%b-%y at %I:%M %p"),
												name: @order.sys_user.name,
												status: @order.status,
												amount: @order.amount,
												items: @order.order_items.map { |i|
												{ product: i.product.title,
													marka: i.marka,
													builty_no: i.builty_no,
													vehicle_no: i.vehicle_no,
													challan_no: i.challan_no,
													quantity: i.quantity
												}
												}
                       }
  end

  def sorted_inward_data
	@amount_total =  PurchaseSaleDetail.ransack(params[:q]).result.where(transaction_type: 'InWard').sum(:amount)
    @sorted_data = []
    @pdf_orders.each do |o_i|
      @sorted_data << {
		                id: o_i.id,
                        type: o_i.transaction_type,
												name: o_i.sys_user&.name,
												status: o_i.status,
												amount: o_i.amount,
												items: o_i.purchase_sale_items.map { |c_i|
												{ product: c_i.product&.title,
													marka: c_i.size_13,
													builty_no: c_i.size_12,
													vehicle_no: c_i.size_11,
													challan_no: c_i.size_10,
													quantity: c_i.size_9,
													room_num: c_i.size_8,
													rack_num: c_i.size_7
												}
												}
                       }
    end
	@sorted_data = @sorted_data.sort_by { |ord| ord[:id] }.reverse if (@sorted_data.present? && params[:pdf].eql?("Total Purchase PDF A8 Desc"))
  end

  def sorted_inward_show_data
	order_total = @purchase_sale_detail.purchase_sale_items&.pluck('purchase_sale_items.size_9').compact&.map(&:to_f).sum
    @sorted_data = []
      @sorted_data << {
		                id: @purchase_sale_detail.id,
                        type: @purchase_sale_detail.transaction_type,
						amount: @purchase_sale_detail.amount,
						total_quantity: order_total,
						date: @purchase_sale_detail.created_at&.strftime("%d-%b-%y at %I:%M %p"),
												name: @purchase_sale_detail.sys_user.name,
												status: @purchase_sale_detail.status,
												amount: @purchase_sale_detail.amount,
												items: @purchase_sale_detail.purchase_sale_items.map { |c_i|
												{ product: c_i.product.title,
													marka: c_i.size_13,
													builty_no: c_i.size_12,
													vehicle_no: c_i.size_11,
													challan_no: c_i.size_10,
													quantity: c_i.size_9,
													room_num: c_i.size_8,
													rack_num: c_i.size_7
												}
												}
                       }
  end
end
def sorted_inward_bill_data
	order_total = @purchase_sale_detail.purchase_sale_items&.pluck('purchase_sale_items.size_9').compact&.map(&:to_f).sum
	mazdoori_total = @purchase_sale_detail.purchase_sale_items&.pluck('purchase_sale_items.size_2').compact&.map(&:to_f).sum
	bill_total = @purchase_sale_detail.purchase_sale_items&.sum(:total_pandri_bill)
    @sorted_data = []
      @sorted_data << {
		                id: @purchase_sale_detail.id,
                        type: @purchase_sale_detail.transaction_type,
						total_quantity: order_total,
						total_mazdoori: mazdoori_total,
						total_bill: bill_total,
						date: @purchase_sale_detail.created_at&.strftime("%d-%b-%y at %I:%M %p"),
												name: @purchase_sale_detail.sys_user.name,
												status: @purchase_sale_detail.status,
												amount: @purchase_sale_detail.amount,
												items: @purchase_sale_detail.purchase_sale_items.map { |c_i|
												{ product: c_i.product.title,
													marka: c_i.size_13,
													builty_no: c_i.size_12,
													vehicle_no: c_i.size_11,
													close_date: c_i.closed_date&.strftime("%d-%b-%y"),
													quantity: c_i.size_9,
													rent_pandri: c_i.rent_pandri,
													panelty_pandri: c_i.panelty_pandri,
													total_pandri_bill: c_i.total_pandri_bill,
													total_mazdoori: c_i.size_2
												}
												}
                       }
  end