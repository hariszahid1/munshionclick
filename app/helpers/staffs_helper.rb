module StaffsHelper
  def staff_paid_this_month_salary?(teacher)
    @staffs_pays.find_by(staff_id: teacher.id).present? if @staffs_pays.present?
  end
  def get_data_for_staffs_details_csv
    @monthly_wage=0
    temp=[]
		@staffs.each do |staff|
      @monthly_wage += staff.staff_salary_or_wage.to_f.round(2)
			first = "#{staff.department.present? ? staff.department.title : ""}: #{staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ""}"
			second = staff.code
			third = "#{staff.name} #{staff.father}"
      forth = "#{staff.staff_salary_or_wage.to_f.round(2)}"
      fifth = staff.advance_amount.to_f.round(2)
      sixth = staff.wage_debit.to_f.round(2)
      seventh = staff.balance.to_f.round(2)
			temp.push([first, second, third, forth, fifth, sixth, seventh])
		end
    temp.push(["Total", "", "", @monthly_wage.round(2), @total.first.first.round(2), @total.first.last.round(2), @total.first.second.round(2)])
		return temp
  end

  def get_data_for_staffs_wage_details_csv
    @monthly_wage = 0
		@advance = 0
		@short_pay = 0
		@balance = 0
    temp=[]
		@staffs.each do |staff|
      if staff.wage_rate.to_i.positive?
        @monthly_wage += staff.staff_salary_or_wage.to_f.round(2)
        @balance += staff.balance.to_f.round(2)
        @short_pay += staff.wage_debit.to_f.round(2)
        @down_payment += staff.advance_amount.to_f.round(2)
        first = "#{staff.department.present? ? staff.department.title : ""}: #{staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ""}",
        second = staff.code,
        third = "#{staff.name} #{staff.father}",
        forth = "#{staff.staff_salary_or_wage.to_f.round(2)}",
        fifth = staff.advance_amount.to_f.round(2),
        sixth = staff.wage_debit.to_f.round(2),
        seventh = staff.balance.to_f.round(2)
      end
			temp.push([first, second, third, forth, fifth, sixth, seventh])
		end
    temp.push(["Total", "", "", @monthly_wage.round(2), @down_payment, @short_pay, @balance])
		return temp
  end

  def get_data_for_staffs_salary_details_csv
    @monthly_wage = 0
		@advance = 0
		@short_pay = 0
		@balance = 0
    temp=[]
    @staffs.each do |staff|
      if staff.monthly_salary.to_i > 0
        @monthly_wage += staff.staff_salary_or_wage.to_f.round(2)
        @advance += staff.advance_amount.to_f.round(2)
        @short_pay += staff.wage_debit.to_f.round(2)
        @balance += staff.balance.to_f.round(2)
        first = "#{staff.department.present? ? staff.department.title : ""}: #{staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ""}"
        second = staff.code
        third = "#{staff.name} #{staff.father}"
        forth = "#{staff.staff_salary_or_wage.to_f.round(2)}"
        fifth = staff.advance_amount.to_f.round(2)
        sixth = staff.wage_debit.to_f.round(2)
        seventh = staff.balance.to_f.round(2)
      end
      temp.push([first, second, third, forth, fifth, sixth, seventh])
    end
    temp.push(["Total", "", "", @monthly_wage, @advance, @short_pay, @balance])
    return temp
  end
end
