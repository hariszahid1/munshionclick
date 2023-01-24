# frozen_string_literal: true

# Outwards Helper
module OutwardsHelper

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
                                                        quantity: i.comment
                                                    }
                                                    }
                        }
        end
        @sorted_data = @sorted_data.sort_by { |ord| ord[:id] }.reverse if (@sorted_data.present? && params[:pdf].eql?("Total Sale PDF A8 Desc"))
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
                                                    amount: @order.amount,
                                                    items: @order.order_items.map { |i|
                                                    { product: i.product.title,
                                                        marka: i.marka,
                                                        challan_no: i.challan_no,
                                                        quantity: i.comment
                                                    }
                                                    }
                           }
    end
end