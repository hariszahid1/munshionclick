# frozen_string_literal: true

# CSV Methods
module LedgerBooksCsvMethods
  extend ActiveSupport::Concern
  def single_user_ledger
    CSV.generate do |csv|
			csv.add_row ["------------------"]
      csv.add_row ["#{@ledger_books&.first&.sys_user&.name} Ledger Book"]
			csv.add_row ["------------------"]

      csv.add_row ["Report by : #{@current_user.name}"]
      csv.add_row ["DateTime : #{Time.zone.now}"]
			csv.add_row ["------------------"]

      csv.add_row ['Sr#', 'Date', 'Bill', 'Job', 'Comment', 'Debit', 'Credit', 'Balance']
			if @ledger_books.total_count == @sys_user.ledger_books.count && params[:submit_form_without].present?
				if (@sys_user.opening_balance.to_i > 0 ) 
					balance="J/Payable"
				elsif (@sys_user.opening_balance.to_i < 0 ) 
					balance="B/Rec"
				else
					balance="Nl"
				end
				csv.add_row ["-", "#{sys_user.created_at.strftime("%d-%b-%y")}", "-", "-", "Opening Balance", "-", "-", "#{@sys_user.opening_balance} : #{balance}"]
			elsif params[:submit_form_without].present?
				@pre_balance=(@ledger_books&.first&.balance.to_i-(@ledger_books&.first&.credit.to_i-@ledger_books&.first&.debit.to_i)).round(0)
				if (@pre_balance > 0 ) 
					balance="J/Payable"
			 elsif (@pre_balance < 0 ) 
				balance="B/Rec"
			 else
				 balance="Nl"
			 end
				csv.add_row ["-", "-", "-", "-", "Previous Balance", "-", "-", "#{balance}"]
			end	

			@ledger_books_pdf.each do |ledger_book|
				temp=''
				if ledger_book.purchase_sale_detail_id.present? 
					if ledger_book.purchase_sale_detail.transaction_type=="Sale"
						temp +='bill'
					end
					if ledger_book.purchase_sale_detail.transaction_type=="Purchase"
					temp+="Purchase"
					end
				elsif ledger_book.order.present? 
					if ledger_book.order.transaction_type=="Sale"
						temp+="Sale Order"
					end
					if ledger_book.order.transaction_type=="Purchase"
						temp+="Purchase Order"
					end
				else
						temp+= "Ledger Book"
				end

				temp+= ledger_book.comment.to_s 
					 
				if ledger_book.account.present?
					temp +="Casher: #{ledger_book.account.title}"
				end
				if (ledger_book.balance.to_i > 0 ) 
					balance="J/Payable"
				elsif (ledger_book.balance.to_i < 0 ) 
					balance="B/Rec"
				else
					balance="Nl"
				end

				csv.add_row ["#{ledger_book.id}", "#{ledger_book.created_at.strftime("%d-%b-%y")}", "#{ledger_book&.purchase_sale_detail&.bill_no}", "#{ledger_book&.purchase_sale_detail&.job_no}", "#{temp}", "#{ledger_book.debit}", "#{ledger_book.credit}", "#{balance}"]
			
			end

			if @ledger_books.total_count == @sys_user.ledger_books.count && params[:submit_pdf_without].present?
				@pre_balance=@sys_user.opening_balance
				temp_6th_column=@sys_user.opening_balance
				if (@sys_user.opening_balance.to_i > 0 ) 
					temp_6th_column="J/Payable"
				elsif (@sys_user.opening_balance.to_i < 0 ) 
					temp_6th_column="B/Rec"
				else
					temp_6th_column="Nl"
				end
				csv.add_row ["#{@sys_user.created_at.strftime("%d-%b-%y")}", "-", "-", "-", "-", "#{temp_6th_column}", "Opening Balance"]
			elsif params[:submit_pdf_without].present?
				@pre_balance=(@ledger_books&.first&.balance.to_i-(@ledger_books&.first&.credit.to_i-@ledger_books&.first&.debit.to_i)).round(0)
				if (@pre_balance > 0 ) 
					temp+="J/Payable"
				elsif (@pre_balance < 0 ) 
					temp+="B/Rec"
				else
					temp+="Nl"
				end
				csv.add_row ["", "-", "-", "-", "-", "#{@pre_balance}", "#{temp}","Previous Balance"]
			end

			@debit=@ledger_books_pdf.pluck(:debit).compact.sum
			(@credit=@ledger_books_pdf.pluck(:credit).compact.sum)
      csv.add_row ["Total", "", "", "", "#{@credit-@debit}", "#{@debit}", "#{@credit}", ""]
			
			@debit=@ledger_books_pdf.pluck(:debit).compact.sum
			(@credit=@ledger_books_pdf.pluck(:credit).compact.sum)
      csv.add_row ["", "Previous", "", "", "#{@debit}", "#{@pre_balance.to_i}", "", ""]

			csv.add_row ["-----", "-------", "-------", "--------", "-------", "------", "-----", "-----"]
      csv.add_row ["-----", "-------", "-------", "--------", "-------", "------", "-----", "-----"]

			if pos_setting_sys_type!="CustomClear" and pos_setting_sys_type!="Draw" and @products_count.present?
				@total = 0
				csv.add_row ["Sale Product Detail"]
				csv.add_row ["items", "Qty"]
				@products_count.each_with_index do |item,i|
					@total += item&.last&.to_f.round(2)
					csv.add_row ["#{item.first}", "#{item&.last&.to_f.round(2)}"]
				end	
			csv.add_row ["Total", "#{@total}"]
			end

			if pos_setting_sys_type!="CustomClear" and pos_setting_sys_type!="Draw"  and @products_purchase_count.present?
				@total = 0
				csv.add_row ["Purchase Product Detail"]

				csv.add_row ["items", "Qty"]
				@products_count.each_with_index do |item,i|
					@total += item&.last&.to_f.round(2)
					csv.add_row ["#{item.first}", "#{item&.last&.to_f.round(2)}"]
				end	
			 csv.add_row ["Total", "#{@total}"]
			end


			



			# csv do end
		end
	end

	def asc_csv
		CSV.generate do |csv|
			csv.add_row ["------------------"]
      csv.add_row ["User Ledger Book"]
			csv.add_row ["------------------"]
			csv.add_row ["Report by : #{@current_user.name}"]
			csv.add_row ["DateTime : #{Time.zone.now}"]
			csv.add_row ["------------------"]
			csv.add_row ['Date', 'User', 'Debit', 'Credit', 'Balance', 'Voucher', 'Comment', 'Balance']

			if @ledger_books.total_count == @sys_user.ledger_books.count && (params[:submit_form].present? or params[:submit_form_without].present?)
				@pre_balance=@sys_user.opening_balance


				csv.add_row [
					"#{@sys_user.created_at.strftime("%d-%b-%y")}",
					"#{@sys_user.name}",
					"-",
					"-",
					"#{@sys_user.opening_balance}",
					"#{}"
				
				
				]
			end
		
		
		
		
		
		
		end #csv end

	end # function end

	def debit_csv
		CSV.generate do |csv|
			csv.add_row ["--------------------------------------------------------------"]
			csv.add_row ["Received In Accounts #{@created_at_gteq} - #{@created_at_lteq}"]
			csv.add_row ["--------------------------------------------------------------"]

			csv.add_row ['Name', 'Received']
				@account_credit.each do |debit|
					csv.add_row [debit.first,debit.last]					
				end
				list=0
				@account_credit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']
			
			# next
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ["Received Payments On Order  #{@created_at_gteq} - #{@created_at_lteq}"]
			csv.add_row ['--------------------------------------------------------------']
			
			csv.add_row ['Name', 'Received']
			@order_customer_credit.each do |debit|
				csv.add_row [debit.first,debit.last]					
			end
			list=0
			@order_customer_credit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']
			
			# next
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ["Received Payments On Sale  #{@created_at_gteq} - #{@created_at_lteq}"]
			csv.add_row ['--------------------------------------------------------------']
			
			csv.add_row ['Name', 'Received']
			@sale_customer_credit.each do |debit|
				csv.add_row [debit.first,debit.last]					
			end
			list=0
			@sale_customer_credit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']

				
			# next
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ["Received Payments  #{@created_at_gteq} - #{@created_at_lteq}"]
			csv.add_row ['--------------------------------------------------------------']
			
			csv.add_row ['Name', 'Received']
			@customer_credit.each do |debit|
				csv.add_row [debit.first,debit.last]					
			end
			list=0
			@customer_credit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']
		
			# next
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ["Received Payments By Date"]
			csv.add_row ['--------------------------------------------------------------']
			
			csv.add_row ['Name', 'Received']
			@customer_credit_date.each do |debit|
				csv.add_row [debit.first,debit.last]					
			end
			list=0
			@customer_credit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']
		

			# next
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ["Paid Payments"]
			csv.add_row ['--------------------------------------------------------------']
			
			csv.add_row ['Name', 'Paid']
			@supplier_debit.each do |debit|
				csv.add_row [debit.first,debit.last]					
			end
			list=0
			@supplier_debit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']
		
			# next
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ["Paid Payments By Date"]
			csv.add_row ['--------------------------------------------------------------']
			
			csv.add_row ['Name', 'Paid']
			@supplier_debit_date.each do |debit|
				csv.add_row [debit.first,debit.last]					
			end
			list=0
			@supplier_debit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']
		
		
		
		end
	end

	def credit_csv
		CSV.generate do |csv|
			csv.add_row ["Report by #{current_user.name}"]
			csv.add_row ["DateTime #{Time.zone.now}"]


			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ["Delivered Products"]
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Name', 'Product Amount']
				@customer_debit.each do |debit|
					csv.add_row [debit.first,debit.last]					
				end
				list=0
				@customer_debit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']
		
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ["Delivered Products By Date"]
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Name/Date', 'Product Amount']
				@customer_debit_date.each do |debit|
					csv.add_row [debit.first,debit.last]					
				end
				list=0
				@customer_debit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']

			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ["Received Products"]
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Name', 'Debit']
				@supplier_credit.each do |debit|
					csv.add_row [debit.first,debit.last]					
				end
				list=0
				@supplier_credit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']

			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ["Received Products by Date"]
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Name/Date', 'Debit']
				@supplier_credit.each do |debit|
					csv.add_row [debit.first,debit.last]					
				end
				list=0
				@supplier_credit.collect{|p| list+=p.last}
			csv.add_row ['--------------------------------------------------------------']
			csv.add_row ['Total',list]	
			csv.add_row ['--------------------------------------------------------------']
		
		
		
		
		
		
		
		
		end
	end



end
