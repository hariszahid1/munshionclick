module StaffsHelper
  def staff_paid_this_month_salary?(teacher)
    @staffs_pays.find_by(staff_id: teacher.id).present? if @staffs_pays.present?
  end
end
