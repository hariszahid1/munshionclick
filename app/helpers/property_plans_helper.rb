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
		temp=[]
		@property_installments.each do |installment|
			first = installment.id
			second = installment&.property_plan&.order&.sys_user&.name
			third =  installment.property_plan.order&.sys_user&.contact&.phone
			fourth = installment.property_plan.order&.order_items_names_and_quantity.to_s&.first.first
			fifth = installment.property_plan.order&.order_items_names_and_quantity.to_s.first[8].to_s + '-M' + installment.property_plan.order&.order_items_names_and_quantity.to_s.first[9].to_s + '-sqr'
			sixth = installment.property_plan.order&.sys_user&.ledger_books&.where('credit>0')&.last&.credit
			seventh = installment.property_plan.order&.sys_user&.ledger_books&.where('credit>0')&.last&.created_at&.strftime("%d%b%y at %I:%M%p")
			eighth = installment.installment_price
			ninth = installment&.due_date&.strftime('%d%b%y')
		  tenth = installment&.property_plan&.order&.order_plot_dealer&.first&.staff&.name if installment&.property_plan&.order&.order_plot_dealer != 0
			temp.push([first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth])
		end
		return temp
	end
end
