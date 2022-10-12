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
			csv.add_row ['Date', 'User', 'Debit', 'Credit', 'Balance', 'Voucher', 'Comment']

			if @ledger_books.total_count == @sys_user.ledger_books.count && (params[:submit_form].present? or params[:submit_form_without].present?)
				@pre_balance=@sys_user.opening_balance
				byebug
				if (ledger_book.balance.to_i > 0 ) 
					balance="J/Payable"
				elsif (ledger_book.balance.to_i < 0 ) 
					balance="B/Rec"
				else
					balance="Nill"
				end

				csv.add_row [
					"#{@sys_user.created_at.strftime("%d-%b-%y")}",
					"#{@sys_user.name}",
					"-",
					"-",
					"#{@sys_user.opening_balance}",
					"#{balance}",
					"Opening Balance"
				]
			elsif (params[:submit_form].present? or params[:submit_form_without].present?)
				@pre_balance=(@ledger_books&.first&.balance.to_i-(@ledger_books&.first&.credit.to_i-@ledger_books&.first&.debit.to_i)).round(0)
				byebug
				if (@pre_balance > 0 )
					balance="J/Payable"
				elsif (@pre_balance < 0 )
					balance="B/Rec"
				else
					balance="Nill"
				end
				csv.add_row [
					"-",
					"#{@sys_user.name}",
					"-",
					"-",
					"#{@pre_balance}",
					"#{balance}",
					"Previous Balance"
				]
			end

			@ledger_books_pdf.each do |ledger_book|
				temp=''
				if ledger_book.purchase_sale_detail_id.present? 
					if ledger_book.purchase_sale_detail.transaction_type=="Sale"
						temp +='Delivery'
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
					# temp +="Casher: #{ledger_book.account.title}"
					 
				if ledger_book.order.present?
					if ledger_book.order.order_items_names_and_quantity!=0
						ledger_book.order.order_items_names_and_quantity.each do |name_quantity|
						temp+=name_quantity.first
						temp+=" || Qty : #{name_quantity.second}"
						temp+=" || Rate : #{name_quantity.third}"
						temp+=" || Total : #{name_quantity.fourth}"
						temp+=" || Total : #{name_quantity.fourth}"
						end
					end
				elsif ledger_book.purchase_sale_detail.present?
					if ledger_book.purchase_sale_detail.purchase_sale_items_names_and_quantity!=0
						ledger_book.purchase_sale_detail.purchase_sale_items_names_and_quantity.each do |name_quantity|
							if ledger_book.purchase_sale_detail.transaction_type=="Purchase"
								temp+=" || #{name_quantity[9]&.first.to_s} - #{+name_quantity.first}"
								temp+=" || Qty : #{name_quantity.second.to_i}"
								temp+=" || Rate : #{name_quantity[5].to_f}"
								temp+=" || Total : #{(name_quantity.second*(name_quantity[5].to_f)).to_i}"
								temp+=" || Carriage/Loading : #{ledger_book.purchase_sale_detail.carriage.to_i+ledger_book.purchase_sale_detail.loading.to_i}"
								temp+=" || Rate : #{name_quantity[5].to_f}"
							else
								temp +=" || #{name_quantity[9]&.first.to_s+'-'+name_quantity.first}"
								temp+=" || Qty : #{name_quantity.second.to_i}"
								if ApplicationController.new.pos_type_batha
									temp2=name_quantity.third.to_f*100
								else
								temp2=name_quantity.third.to_f
								end
								temp+=" || Rate : #{temp2}"
								temp+=" || total #{(name_quantity.second*(name_quantity.third.to_f)).to_i}"
								temp+=" || Carriage/loading : #{ledger_book.purchase_sale_detail.carriage.to_i+ledger_book.purchase_sale_detail.loading.to_i}"
							end
						end
						if ledger_book.purchase_sale_detail.with_gst.present?
							temp+=" || GST : #{ledger_book.purchase_sale_detail.purchase_sale_items.sum(:gst_amount)}"
						end
						if ledger_book&.purchase_sale_detail&.bill_no.present?
							temp+=" || PO# : #{ledger_book&.purchase_sale_detail&.bill_no}"
						end

					end
				end

				if ledger_book.account.present?
					temp+="Casher : #{ledger_book.account.title}"
				end 

				if (ledger_book.balance.to_i > 0 ) 
					voucher="J/Payable"
				elsif (ledger_book.balance.to_i < 0 ) 
					voucher="B/Rec"
				else
					voucher="Nl"
				end

				csv.add_row [
					"#{ledger_book.created_at.strftime("%d-%b-%y")}",
					 "#{ledger_book.sys_user.name}",
					  "#{ledger_book.debit}",
						 "#{ledger_book.credit}",
						  "#{ledger_book.balance}",
								"#{voucher}",
								 "#{temp}",
								  "#{}"
											]
			
			end

			if @ledger_books.total_count == @sys_user.ledger_books.count && (params[:submit_pdf_without].present? or params[:submit_pdf_without].present?)
				pre_balance=@sys_user.opening_balance
				if (ledger_book.balance.to_i > 0 ) 
					balance="J/Payable"
				elsif (ledger_book.balance.to_i < 0 ) 
					balance="B/Rec"
				else
					balance="Nill"
				end
				
				csv.add_row [
					@sys_user.created_at.strftime("%d-%b-%y"),
					@sys_user.name,
					"-",
					"-",
					"#{@balance}",
					"Opening Balance"

				]
			elsif (params[:submit_pdf_without].present? or params[:submit_pdf_without].present?)
				@pre_balance=(@ledger_books&.first&.balance.to_i-(@ledger_books&.first&.credit.to_i-@ledger_books&.first&.debit.to_i)).round(0)
				if (ledger_book.balance.to_i > 0 ) 
					balance="J/Payable"
				elsif (ledger_book.balance.to_i < 0 ) 
					balance="B/Rec"
				else
					balance="Nill"
				end

				csv.add_row [
					"",
					@sys_user.name,
					"-",
					"-",
					"#{@balance}",
					"Previous Balance"
					"#{}"
				]
			end
			# byebug
			@debit=@ledger_books_pdf.pluck(:debit).compact.sum
			(@credit=@ledger_books_pdf.pluck(:credit).compact.sum)
			temp=@credit-@debit
			csv.add_row [
				"Total",
				"",
				"#{@debit}",
				"#{@credit}",
				"",
				"#{temp}",
				"#{@credit} - #{@debit}"
			]

			csv.add_row [
				"Total",
				"",
				"Previous",
				"#{@pre_balance.to_i}",
				"",
				"",
				""
			]
			
			csv.add_row [
				"Total",
				"",
				"",
				"#{@pre_balance.to_i+(@credit=@ledger_books_pdf.pluck(:credit).compact.sum)}",
				"#{(@pre_balance.to_i+@credit)-@debit}",
				"",
				"#{@pre_balance.to_i} + #{@credit} -#{@debit}"
			]
		
			if @products_count.present?
				@total=0
				@products_count.each_with_index do |item,i|
					@total += item&.last&.to_f.round(2)
					csv.add_row [item.first,item&.last.to_f.round(2)]
				end

				csv.add_row ['Total',"#{@total}"]
			end


			if @products_count_return.present?
				csv.add_row ["Sale Return Product Detail"]
				@total=0
				@products_count_return.each_with_index do |item,i|
					@total += item&.last&.to_f.round(2)
					csv.add_row [item.first,item&.last.to_f.round(2)]
				end

				csv.add_row ['Total',"#{@total}"]
			end

			if @products_purchase_count.present?
				csv.add_row ["Purchase Product Detail"]
				@total=0
				@products_purchase_count.each_with_index do |item,i|
					@total += item&.last&.to_f.round(2)
					csv.add_row [item.first,item&.last.to_f.round(2)]
				end

				csv.add_row ['Total',"#{@total}"]
			end

			if @products_purchase_count_return.present?
				csv.add_row ["Purchase Return Product Detail"]
				@total=0
				@products_purchase_count_return.each_with_index do |item,i|
					@total += item&.last&.to_f.round(2)
					csv.add_row [item.first,item&.last.to_f.round(2)]
				end

				csv.add_row ['Total',"#{@total}"]
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
