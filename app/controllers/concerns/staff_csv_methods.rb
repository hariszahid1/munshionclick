module StaffCsvMethods
  extend ActiveSupport::Concern
	def staff_details_csv
		@monthly_wage=0
 		@time = Time.zone.now 
		CSV.generate do |csv|
			csv.add_row ["--------------------------------------"]
			csv.add_row ["Staff Detail"]
			csv.add_row ["--------------------------------------"]
			csv.add_row ["Printing Date Time #{@time.strftime("%d")} / #{@time.strftime("%b")} / #{@time.strftime("%y")} / #{@time.strftime("at %I:%M%p")}"]
			csv.add_row ["Current User #{@current_user.name}"]
			csv.add_row ['Department/Raw','Code','Name','Monthly/Wage','Advance','Short-pay','Balance']

			@staffs_pdf.each do |staff|
				@monthly_wage += staff.staff_salary_or_wage.to_f.round(2)
				csv.add_row [
					"#{staff.department.present? ? staff.department.title : ""}: #{staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ""}",
					staff.code,
					"#{staff.name} #{staff.father}",
					"#{staff.staff_salary_or_wage.to_f.round(2)}",
					staff.advance_amount.to_f.round(2),
					staff.wage_debit.to_f.round(2),
					staff.balance.to_f.round(2)
				]
			end
			csv.add_row [
				"Total",
				"",
				"",
				@monthly_wage.round(2),
				@total.first.first.round(2),
				@total.first.last.round(2),
				@total.first.second.round(2)
			]
		end
	end

	def wage_staff_details_csv
		@monthly_wage=0
		@advance=0
		@short_pay=0
		@balance=0
		@time = Time.zone.now 
		CSV.generate do |csv|
			csv.add_row ["--------------------------------------"]
			csv.add_row ["Wage Staff Detail"]
			csv.add_row ["--------------------------------------"]
			csv.add_row ["Printing Date Time #{@time.strftime("%d")} / #{@time.strftime("%b")} / #{@time.strftime("%y")} / #{@time.strftime("at %I:%M%p")}"]
			csv.add_row ["Current User #{@current_user.name}"]
			csv.add_row ['Department/Raw','Code','Name','Monthly/Wage','Down Payment','Short-pay','Balance']

			@staffs_pdf.each do |staff|
				if staff.wage_rate.to_i > 0
					@monthly_wage += staff.staff_salary_or_wage.to_f.round(2)
					@short_pay += staff.wage_debit.to_f.round(2)
					@balance += staff.balance.to_f.round(2)
					@monthly_wage += staff.staff_salary_or_wage.to_f.round(2)
					csv.add_row [
						"#{staff.department.present? ? staff.department.title : ""}: #{staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ""}",
						staff.code,
						"#{staff.name} #{staff.father}",
						"#{staff.staff_salary_or_wage.to_f.round(2)}",
						staff.advance_amount.to_f.round(2),
						staff.wage_debit.to_f.round(2),
						staff.balance.to_f.round(2)
					]
				end
			end
		end
	end

	def salary_staff_details_csv
		@monthly_wage=0
		@advance=0
		@short_pay=0
		@balance=0
		@time = Time.zone.now 
		CSV.generate do |csv|
			csv.add_row ["--------------------------------------"]
			csv.add_row ["Salary Staff Detail"]
			csv.add_row ["--------------------------------------"]
			csv.add_row ["Printing Date Time #{@time.strftime("%d")} / #{@time.strftime("%b")} / #{@time.strftime("%y")} / #{@time.strftime("at %I:%M%p")}"]
			csv.add_row ["Current User #{@current_user.name}"]
			csv.add_row ['Department/Raw','Code','Name','Monthly/Wage','Advance','Short-pay','Balance']

			@staffs_pdf.each do |staff|
				if staff.monthly_salary.to_i > 0
					@monthly_wage += staff.staff_salary_or_wage.to_f.round(2)
					@short_pay += staff.wage_debit.to_f.round(2)
					@balance += staff.balance.to_f.round(2)
					csv.add_row [
						"#{staff.department.present? ? staff.department.title : ""}: #{staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ""}",
						staff.code,
						"#{staff.name} #{staff.father}",
						"#{staff.staff_salary_or_wage.to_f.round(2)}",
						staff.advance_amount.to_f.round(2),
						staff.wage_debit.to_f.round(2),
						staff.balance.to_f.round(2)
					]
				end
			end
		end
	end

	def payable_staff_details_csv
		@monthly_wage=0
		@advance=0
		@short_pay=0
		@balance=0
		@date = Date.today  
		@time = DateTime.now 
		@time = Time.zone.now 
		CSV.generate do |csv|
			csv.add_row ["--------------------------------------"]
			csv.add_row ["Payable Staff Details"]
			csv.add_row ["--------------------------------------"]
			# csv.add_row ["Printing Date Time #{@time.strftime("%d")} / #{@time.strftime("%b")} / #{@time.strftime("%y")} / #{@time.strftime("at %I:%M%p")}"]
			csv.add_row ["Current User #{@current_user.name}"]
			csv.add_row ['Status','Code','Name','Father','Date of joining','Monthly/Wage','Advance','Department/Raw','Short-pay','Balance']

			@staffs.each do |staff|
				if staff.balance > 0
					temp_date=staff.date_of_joining.strftime("%A,  %d-%b-%y") if staff.date_of_joining
					temp_department= (staff.department.present? ? staff.department.title : "") + (staff.staff_raw_products.present? ? staff.staff_raw_products_titles : "")
					@monthly_wage += staff.staff_salary_or_wage.to_f.round(2)
					@advance += staff.advance_amount.to_f.round(2)
					@short_pay += staff.wage_debit.to_f.round(2)
					@balance += staff.balance.to_f.round(2)

					csv.add_row [
						staff.staff_type,
						staff.code,
						staff.name,
						staff.father,
						temp_date,
						staff.staff_salary_or_wage.to_f.round(2),
						staff.advance_amount.to_f.round(2),
						temp_department,
						staff.wage_debit.to_f.round(2),
						staff.balance.to_f.round(2)
					]
				end
			end
			csv.add_row [
				"Total",
				"",
				"",
				"",
				"",
				@monthly_wage.round(2),
				@advance.round(2),
				"",
				@short_pay.round(2),
				@balance.round(2)
			]
		end
	end

	def receiveable_staff_details_csv
		@monthly_wage=0
		@advance=0
		@short_pay=0
		@balance=0
		@date = Date.today  
		@time = DateTime.now 
		@time = Time.zone.now 
		CSV.generate do |csv|
			csv.add_row ["--------------------------------------"]
			csv.add_row ["Reciveable Staff Details"]
			csv.add_row ["--------------------------------------"]
			# csv.add_row ["Printing Date Time #{@time.strftime("%d")} / #{@time.strftime("%b")} / #{@time.strftime("%y")} / #{@time.strftime("at %I:%M%p")}"]
			csv.add_row ["Current User #{@current_user.name}"]
			csv.add_row ['Status','Code','Name','Father','Date of joining','Monthly/Wage','Advance','Department/Raw','Short-pay','Balance']

			@staffs.each do |staff|
				if staff.balance < 0
					temp_date=staff.date_of_joining.strftime("%A,  %d-%b-%y") if staff.date_of_joining
					temp_department= (staff.department.present? ? staff.department.title : "") + (staff.staff_raw_products.present? ? staff.staff_raw_products_titles : "")
					@monthly_wage += staff.staff_salary_or_wage.to_f.round(2)
					@advance += staff.advance_amount.to_f.round(2)
					@short_pay += staff.wage_debit.to_f.round(2)
					@balance += staff.balance.to_f.round(2)

					csv.add_row [
						staff.staff_type,
						staff.code,
						staff.name,
						staff.father,
						temp_date,
						staff.staff_salary_or_wage.to_f.round(2),
						staff.advance_amount.to_f.round(2),
						temp_department,
						staff.wage_debit.to_f.round(2),
						staff.balance.to_f.round(2)
					]
				end
			end
			csv.add_row [
				"Total",
				"",
				"",
				"",
				"",
				@monthly_wage.round(2),
				@advance.round(2),
				"",
				@short_pay.round(2),
				@balance.round(2)
			]
		end
	end
end