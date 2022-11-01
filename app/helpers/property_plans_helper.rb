module PropertyPlansHelper
    def get_data_for_property_plan_csv
		temp=[]
		@property_plan.each do |property_plan|
			first=property_plan.id
			second=property_plan.order&.sys_user&.name
			third= property_plan.order&.sys_user&.contact&.phone
			fourth=property_plan.order&.order_items_names_and_quantity&.first&.first
            fifth=property_plan.order&.sys_user&.ledger_books.where('credit>0')&.last&.credit
            sixth=property_plan.order&.sys_user&.ledger_books.where('credit>0')&.last&.created_at&.strftime("%d%b%y at %I:%M%p")
            seventh=property_plan.advance 
            eighth=property_plan.order&.order_items_names_and_quantity&.first[8]
            ninth=property_plan.due_date.present? ? property_plan.due_date.strftime("%d%b%y at %I:%M%p") : ''
			temp.push([first, second, third, fourth,fifth,sixth,seventh,eighth,ninth])
		end
		return temp
	end
end
