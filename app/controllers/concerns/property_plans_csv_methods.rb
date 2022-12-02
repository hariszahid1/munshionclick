module PropertyPlansCsvMethods
  extend ActiveSupport::Concern
	include ActionView::Helpers::NumberHelper

	def get_data_for_index_csv
		temp=[]
		@property_plans.each do |property_plan| 
			if property_plan.order&.sys_user&.id.present?
				first=property_plan.order&.sys_user&.name
			else
				first=""
			end
			second= property_plan.order&.sys_user&.contact&.phone 
			third= property_plan.order&.order_items_names_and_quantity&.first&.first 
			fourth= "#{property_plan.order&.order_items_names_and_quantity&.first[8]}-M  #{property_plan.order&.order_items_names_and_quantity&.first[9]}-sqr"
			fifth="#{number_with_delimiter property_plan.order&.sys_user&.ledger_books.where('credit>0')&.last&.credit}" 
			sixth="#{property_plan.order&.sys_user&.ledger_books.where('credit>0')&.last&.created_at&.strftime("%d%b%y at %I:%M%p")}"
			seventh="#{number_with_delimiter property_plan.advance}" 
			eighth="#{property_plan.due_date.present? ? property_plan.due_date.strftime("%d%b%y at %I:%M%p") : ''}" 
			ninth="#{property_plan&.order&.order_plot_dealer&.first&.staff&.name}"
			temp.push([first,second,third,fourth,fifth,sixth,seventh,eighth,ninth])
		end
		temp.push(["Total",@property_plans.count,"","","","",@total_advance,"",""])
		return temp 
	end
end