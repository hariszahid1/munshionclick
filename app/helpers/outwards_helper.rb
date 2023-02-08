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

    def sorted_outward_data
        @sorted_data = []
        @pdf_orders.each do |o_i|
          @sorted_data << {
                            id: o_i.id,
                            type: o_i.transaction_type,
                                                    name: o_i.sys_user&.name,
                                                    status: o_i.status,
                                                    amount: o_i.amount,
                                                    date: o_i.created_at&.strftime("%d-%b-%y"),
                                                    items: o_i.purchase_sale_items.map { |c_i|
                                                    { product: c_i.product&.title,
                                                        marka: c_i.size_13,
                                                        builty_no: c_i.size_12,
                                                        vehicle_no: c_i.size_11,
                                                        challan_no: c_i.size_10,
                                                        quantity: c_i.quantity,
                                                        room_num: c_i.size_8,
                                                        rack_num: c_i.size_7,
                                                        in_date: c_i.inward_date&.strftime("%d-%b-%y"),
                                                        close_date: c_i.closed_date&.strftime("%d-%b-%y"),
                                                        rent_pandri: c_i.rent_pandri,
                                                        panelty_pandri: c_i.panelty_pandri,
                                                        total_pandri_bill: c_i.total_pandri_bill
                                                    }
                                                    }
                           }
        end
        @sorted_data = @sorted_data.sort_by { |ord| ord[:id] }.reverse if (@sorted_data.present? && params[:pdf].eql?("Total Sale PDF A8 Desc"))
    end

    def sorted_outward_show_data
        order_total = @purchase_sale_detail.purchase_sale_items&.sum(:quantity)
        @sorted_data = []
          @sorted_data << {
                            id: @purchase_sale_detail.id,
                            type: @purchase_sale_detail.transaction_type,
                            total_quantity: order_total,
                            date: @purchase_sale_detail.created_at&.strftime("%d-%b-%y"),
                                                    name: @purchase_sale_detail.sys_user.name,
                                                    status: @purchase_sale_detail.status,
                                                    amount: @purchase_sale_detail.amount,
                                                    items: @purchase_sale_detail.purchase_sale_items.map { |c_i|
                                                    { product: c_i.product.title,
                                                        marka: c_i.size_13,
                                                        builty_no: c_i.size_12,
                                                        vehicle_no: c_i.size_11,
                                                        challan_no: c_i.size_10,
                                                        quantity: c_i.quantity,
                                                        room_num: c_i.size_8,
                                                        rack_num: c_i.size_7,
                                                        in_date: c_i.inward_date&.strftime("%d-%b-%y"),
                                                        close_date: c_i.closed_date&.strftime("%d-%b-%y"),
                                                        rent_pandri: c_i.rent_pandri,
                                                        panelty_pandri: c_i.panelty_pandri,
                                                        total_pandri_bill: c_i.total_pandri_bill
                                                    }
                                                    }
                           }
    end
end