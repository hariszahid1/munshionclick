# frozen_string_literal: true

# CMS Helper
module InwardsHelper

	def sorted_data
    @sorted_data = []
    @pdf_orders.each do |o|
      @sorted_data << {
		                id: o.id, 
                        type: o.transaction_type,
												name: o.sys_user.name,
												status: o.status,
												amount: o.amount,
												items: o.order_items.map { |i|
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
  end

  def sorted_show_data
    @sorted_data = []
      @sorted_data << {
		                id: @order.id,
                        type: @order.transaction_type,
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
end
