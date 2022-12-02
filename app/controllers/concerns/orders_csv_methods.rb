# frozen_string_literal: true

# CSV Methods
module OrdersCsvMethods
  extend ActiveSupport::Concern

	def orders_csv
    
		CSV.generate do |csv|
      csv.add_row [params[:sale].present? ? "Total Unit Sale Booking:" : "Total Unit Purchase Booking:", "#{@products_sale_total}" ]

      csv.add_row ['--------------------------------']
      csv.add_row ["Report by: #{current_user.name}"]
      csv.add_row ["DateTime: #{@time = Time.zone.now}"]
      csv.add_row ['--------------------------------']
      csv.add_row ['Unit', 'Marla','Total']
      
      
      @products_count.each_with_index do |item,i|
        csv.add_row [
          item.first,
          item.last.to_f.round(2),
          @products_sale[item.first].round(2)
        ]
      end

      csv.add_row [params[:sale].present? ? "Total Sale:" : "Total Purchase:", " ", "#{@products_sale_total}"]
      
      if @pos_setting.present?
        csv.add_row [@pos_setting.address]
      end

       if @pos_setting.present?
        csv.add_row [@pos_setting.phone]
      end

		end
	end

end

