module DailySalesCsvMethods
  extend ActiveSupport::Concern

	def get_data_for_daily_sales_csv
		temp=[]

		@salaries.each do |salary|
			first= salary.staff.name
			second=(salary.paid_salary.present? ? "#{salary.paid_salary}" : "" ).to_s+  (salary.advance.present? ? "#{salary.advance}" : "").to_s
			third=salary.staff.balance.to_f.round(2)
			fourth=salary.leaves_in_month
			fifth=salary.account_id.present? ? salary.account.title : ''
			sixth="#{salary.comment} | #{salary.payment_type}"
			if salary.created_at.strftime("%d%b%y")!=salary.updated_at.strftime("%d%b%y")
				seventh="#{salary.created_at.present? ? salary.created_at.strftime("%A,  %d-%b-%y at %H:%M%p") : ''} | #{salary.updated_at.present? ? salary.updated_at.strftime("%d%b%y at %H:%M%p") : ''}"
			else
				seventh="#{salary.created_at.present? ? salary.created_at.strftime("%A,  %d-%b-%y at %H:%M%p") : ''}"
			end
			temp.push([first,second,third,fourth,fifth,sixth,seventh])
		end
		temp.push(["total",@salaries.sum(:paid_salary)+@salaries.sum(:advance)])
		return temp
	end

end

