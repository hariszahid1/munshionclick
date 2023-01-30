module PropertyPlansHelper
  def get_data_for_property_plan_csv
		temp=[]
		@property_plan.each do |property_plan|
			first = property_plan.id
			second = property_plan.order&.sys_user&.name
			third =  property_plan.order&.sys_user&.contact&.phone
			fourth = property_plan.order&.order_items_names_and_quantity&.first&.first
			fifth = property_plan.order&.sys_user&.ledger_books.where('credit>0')&.last&.credit
			sixth = property_plan.order&.sys_user&.ledger_books.where('credit>0')&.last&.created_at&.strftime("%d%b%y at %I:%M%p")
			seventh = property_plan.advance
			eighth = property_plan.order&.order_items_names_and_quantity&.first[8].to_s + "-M" + property_plan.order&.order_items_names_and_quantity&.first[9].to_s + "-sqr"
			ninth = property_plan.due_date.present? ? property_plan.due_date.strftime("%d%b%y at %I:%M%p") : ''
			tenth = property_plan&.order&.order_plot_dealer&.first&.staff&.name
			temp.push([first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth])
		end
		return temp
	end

	def get_data_for_property_installment_csv
		@property_installments.flat_map do |property_plan|
			property_plan.property_installments.map do |pi|
				order = property_plan.order
				user = order.sys_user
				contact = user.contact
				ledger_books = user.ledger_books
				order_items = order.order_items_names_and_quantity
				plot_dealer = order.order_plot_dealer
				staff = plot_dealer&.first&.staff

				[
					pi.id,
					user&.name,
					contact&.phone,
					order_items != 0 ? order_items&.first&.first : '',
					order_items != 0 ? "#{order_items&.first&.[](8)}-M#{order_items&.first&.[](9)}-sqr" : '',
					ledger_books.where("credit > 0").last&.credit,
					ledger_books.where("credit > 0").last&.created_at&.strftime("%d%b%y at %I:%M%p"),
					pi&.installment_price,
					pi&.due_date&.strftime('%d%b%y'),
					staff&.name || ''
				]
			end
		end
	end

end
