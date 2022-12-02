module InvestmentCsvMethods
  extend ActiveSupport::Concern
	include ActionView::Helpers::NumberHelper

	def get_data_for_index_csv
		temp=[]
		@investments.each do |investment|
			@total_investment += investment.invest.to_f.round(2)
			first=investment.id
			second=investment.invest.to_f.round(2)
			third=investment.account_id.present? ? investment.account.title : ''
			fourth=investment.comment
			if investment.created_at.strftime("%d%b%y")!=investment.updated_at.strftime("%d%b%y")
				fifth="#{investment.created_at.present? ? investment.created_at.strftime("%d%b%y at %H:%M%p") : ''} | #{investment.updated_at.present? ? investment.updated_at.strftime("%d%b%y at %H:%M%p") : ''}"
			else
				fifth="#{investment.created_at.present? ? investment.created_at.strftime("%d%b%y at %H:%M%p") : ''} "
			end
			temp.push([first,second,third,fourth,fifth])
		end
		temp.push(["Total",@total_investment.first])
		return temp 
	end
end