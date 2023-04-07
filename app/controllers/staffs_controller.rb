class StaffsController < ApplicationController
  before_action :check_access
	include StaffCsvMethods
  before_action :set_staff, only: [:show, :edit, :update, :destroy, :salary_info, :salary_wage_rate_info]
  before_action :set_edit_new_data, only: %i[new create edit]

  include PdfCsvGeneralMethod
  include StaffsHelper

  # GET /staffs
  # GET /staffs.json
  def index
    @departments=Department.all
    @q = Staff.where(deleted: false).ransack(params[:q])
    if @pos_setting.sys_type.eql?('Dealer')
      if params.dig(:q, :staff_type_eq).present?
        @q = Staff.where(deleted: false).ransack(params[:q])
      else
        @q = Staff.where(deleted: false, staff_type: 'active').ransack(params[:q])
      end
    end
    if @q.result.count > 0
      @q.sorts = ['name asc', 'department_id asc'] if @q.sorts.empty?
    end
    if params[:q].present?
      @name = params[:q][:id_eq]
      @department=params[:q][:department_id_eq]
    end
    if params[:submit_remove_wege_debit]
      @staffs_pdf = @q.result(distinct: true)
      @staffs_pdf.update_all(wage_debit:0)
    end
    @staff_names=Staff.all
    @staffs_total = @q.result(distinct: true)
    @staffs = @q.result(distinct: true).page(params[:page]).per(50)
    @total = @staffs_total.pluck('SUM(advance_amount)','SUM(balance)','SUM(wage_debit)')
    @staffs_pays = Salary.where("extract(month from created_at) = ? AND extract(year from created_at) = ? AND staff_id IN (?)", Date.today.month, Date.today.year,Staff.pluck(:id)).where(:payment_type=>0)
		@staffs_pdf = @q.result(distinct: true)

    download_staffs_csv_file if params[:submit_csv].present? || params[:salary_submit_csv].present? || params[:wage_submit_csv].present?
    download_staffs_pdf_file if params[:submit_pdf].present? || params[:salary_submit_pdf].present? || params[:wage_submit_pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?

    @staff_count = []
    @staff_count.push(Staff.where('balance > 0').count)
    @staff_count.push(Staff.where('balance < 0').count)
    @staff_count.push(Staff.where('balance = 0').count)

    @total_dep_count = Staff.joins(:department).group('departments.title').count
    @dep_title = @total_dep_count.keys.map { |a| a.gsub(' ', '-') }
    @dep_user = @total_dep_count.values

    @balance_sum = []
    @balance_sum.push(Staff.where('balance > 0').sum(:balance).to_f)
    @balance_sum.push(Staff.where('balance < 0').sum(:balance).to_f)

  end

  def payable
    @departments=Department.all
    @q = Staff.where(deleted: false).ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = ['department_id asc','name asc'] if @q.sorts.empty?
    end
    if params[:q].present?
      @name = params[:q][:id_eq]
      @department=params[:q][:department_id_eq]
    end
    @staff_names=Staff.all
    @staffs = @q.result(distinct: true).page(params[:page]).per(50)
    @staffs_pays = Salary.where("extract(month from created_at) = ? AND extract(year from created_at) = ? AND staff_id IN (?)", Date.today.month, Date.today.year,Staff.pluck(:id)).where(:payment_type=>0)
    if params[:submit_pdf]
			print_pdf('payable_staff_details','pdf.html','A4')
		elsif params[:submit_csv]
			csv_data=payable_staff_details_csv
			createCSV("payable_staff_details",csv_data)
    end

  end

  def receiveable
    @departments=Department.all
    @q = Staff.where(deleted: false).ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = ['department_id asc','name asc'] if @q.sorts.empty?
    end
    if params[:q].present?
      @name = params[:q][:id_eq]
      @department=params[:q][:department_id_eq]
    end
    @staff_names=Staff.all
    @staffs = @q.result(distinct: true).page(params[:page]).per(50)
    @staffs_pays = Salary.where("extract(month from created_at) = ? AND extract(year from created_at) = ? AND staff_id IN (?)", Date.today.month, Date.today.year,Staff.pluck(:id)).where(:payment_type=>0)
    if params[:submit_pdf]
      @staffs_pdf = @q.result(distinct: true)
			print_pdf('receiveable_staff_details','pdf.html','A4')
		elsif params[:submit_csv]
			csv_data=receiveable_staff_details_csv
			createCSV("receiveable_staff_details",csv_data)
    end
  end

  def dasti
    @departments=Department.all
    @q = Staff.where(deleted: false).ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = ['department_id asc','name asc'] if @q.sorts.empty?
    end
    if params[:q].present?
      @name = params[:q][:id_eq]
      @department=params[:q][:department_id_eq]
    end
    @staff_names=Staff.all
    @staffs = @q.result(distinct: true).page(params[:page]).per(50)
    @staffs_pays = Salary.where("extract(month from created_at) = ? AND extract(year from created_at) = ? AND staff_id IN (?)", Date.today.month, Date.today.year,Staff.pluck(:id)).where(:payment_type=>0)
    if params[:submit_pdf]
      request.format = 'pdf'
      @staffs_pdf = @q.result(distinct: true)
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "index_staff_wise",
          layout: 'pdf.html',
          page_size: 'A4',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
            right: '[page] of [topage]'},
          show_as_html: false
        end
      end
    end
  end

  # GET /staffs/1
  # GET /staffs/1.json
  def show
    @departments=Department.all
    @raw_products = RawProduct.all

    
  end

  # GET /staffs/new
  def new
    @staff = Staff.new
    @staff.build_contact
  end

  # GET /staffs/1/edit
  def edit
    
  end

  # POST /staffs
  # POST /staffs.json
  def create
    @staff = Staff.new(staff_params)
    respond_to do |format|
      if @staff.save!
        format.html { redirect_to get_request_referrer, notice: 'Staff was successfully created.' }
        format.json { render :show, status: :created, location: @staff }
      else
        @departments=Department.all
        @raw_products = RawProduct.all
        format.html { render :new }
        format.json { render json: @staff.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /staffs/1
  # PATCH/PUT /staffs/1.json
  def update
    respond_to do |format|
      if @staff.update!(staff_params)
        format.html { redirect_to get_request_referrer, notice: 'Staff was successfully updated.' }
        format.json { render :show, status: :ok, location: @staff }
      else
        @departments=Department.all
        @raw_products = RawProduct.all
        format.html { render :edit }
        format.json { render json: @staff.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /staffs/1
  # DELETE /staffs/1.json
  def destroy
    @staff.destroy
    respond_to do |format|
      format.html { redirect_to staffs_path, notice: 'Staff was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @staff }
    end
  end

  def salary_info
    respond_to do |format|
      format.json { render json: {status: 'success', id: @staff.id,balance: @staff.balance, advance_amount: @staff.advance_amount, monthly_salary: @staff.monthly_salary, daily_Salary: (@staff.monthly_salary.to_f / (Time.days_in_month Date.today.month)).round(2),wage_debit: @staff.wage_debit,wage_rate: @staff.wage_rate }, status: :ok}
    end
  end

  def salary_wage_rate_info
    respond_to do |format|
      if @staff.staff_department=="Plant 1"
        @staffs=Staff.where(staff_department:@staff.staff_department).where.not(id:@staff)
      else
        @staffs=Staff.where(id:@staff)
      end
      format.json { render json: {status: 'success', balance: @staff.balance, advance_amount: @staff.balance, wage_rate: @staff.wage_rate ,staffs: @staffs.pluck(:name),staff_ids: @staffs.pluck(:id),staff_count: @staffs.count}, status: :ok}
    end
  end

  def update_balance
    staff = Staff.find(params[:id])
    @credit_sum = StaffLedgerBook.where(staff_id: staff).sum(:credit)
    @debit_sum = StaffLedgerBook.where(staff_id: staff).sum(:debit)
    @updated_balance = @credit_sum.to_f - @debit_sum.to_f
    staff.update(balance: @updated_balance)
    render json: { updated_balance: @updated_balance }
  end

  def view_history
    @start_date = Date.today.beginning_of_month
    @end_date =  Date.today.end_of_month
    if params[:q].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      @item_id = params[:q][:item_id_eq] if params[:q][:item_id_eq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
    @event = %w[create update destroy]
    @q = PaperTrail::Version.where(item_type:"Staff").order('created_at desc').ransack(params[:q])
    @staff_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_staff
    @staff = Staff.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def staff_params
    params.require(:staff).permit(:code, :name, :father, :education, :gender, :phone, :address, :cnic, :date_of_joining, :date_of_leaving, :yearly_increment,
                                  :monthly_salary, :school_branch_id, :wage_rate, :balance, :staff_department, :department_id, :staff_type, :wage_debit,
                                    :raw_product_quantity, :profile_image, :is_agent, :staff_raw_products_attributes => [:id, :staff_id, :raw_product_id, :_destroy],
                                  contact_attributes: [:country_id, :city_id, :address, :home, :office, :Mobile, :fax,
                                    :email, :comment, :status, :permanent_address, :contactable_id, :contactable_type, :date_of_birth])
  end

  def createCSV(csv_name,csv_data)
    request.format = 'csv'
    respond_to do |format|
    format.html
    format.csv { send_data csv_data, filename: "#{csv_name} - #{Date.today}.csv" }
    end
  end

  def download_staffs_csv_file
    @time = Time.zone.now
    set_top_data_for_csv
    @staffs = @q.result
    if params[:salary_submit_csv].present?
      file_name = 'Salary-staffs'
      header_for_csv = %w[Department/Raw Code Name Monthly/Wage Advance Short-pay Balance]
      data_for_csv = get_data_for_staffs_salary_details_csv
    elsif params[:wage_submit_csv].present?
      file_name = 'Wage-staffs'
      header_for_csv = %w[Department/Raw Code Name Monthly/Wage Down_Payment Short-pay Balance]
      data_for_csv = get_data_for_staffs_wage_details_csv
    else
      file_name = 'Staffs'
      header_for_csv = %w[Department/Raw Code Name Monthly/Wage Advance Short-pay Balance]
      data_for_csv = get_data_for_staffs_details_csv
    end
    generate_csv_extra_rows_top(@top_data, data_for_csv, header_for_csv,
                                "#{file_name}-Total-#{@staffs.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
  end

  def download_staffs_pdf_file
    @file_name = ''
    @pdf_html = false
    @pdf_file_path = ''
    sort_data_according
    generate_pdf(@sorted_data.as_json, "#{@file_name}-Total-#{@sorted_data.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}",
                 'pdf.html', 'A4', @pdf_html, @pdf_file_path)
  end

  def send_email_file
    sort_data_according
    EmailMultiFilesJob.perform_later(@sorted_data.as_json, 'staffs/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "staffs-Total-#{@sorted_data.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
    flash[:notice] = if params[:email_value].present?
                       "Email has been sent to #{params[:email_value]}"
                     else
                       "Email has been sent to #{current_user.email}"
                     end
    redirect_to staffs_path
  end

  def sort_data_according
    @sorted_data = []
    @monthly_wage = 0
    @advance_total = 0
    @short_pay_total = 0
    @balance_total = 0
    if params[:submit_pdf]
      @file_name = 'Staffs'
      @pdf_file_path = 'staffs/index.pdf.erb'
      @q.result.each do |d|
        data_for_pdf(d)
      end
    elsif params[:salary_submit_pdf]
      @pdf_html = true
      @file_name = 'Salary-Staffs'
      @q.result.each do |d|
        @pdf_file_path = 'staffs/salary_staff_detail.pdf.erb'
        if d.monthly_salary.to_i > 0
          data_for_pdf(d)
        end
      end
    elsif params[:wage_submit_pdf]
      @file_name = 'Wage-Staffs'
      @pdf_file_path = 'staffs/wage_staff_detail.pdf.erb'
      @q.result.each do |d|
        if d.wage_rate.to_i.positive?
          data_for_pdf(d)
        end
      end
    end
  end

  def data_for_pdf(d)
    @monthly_wage += d.staff_salary_or_wage.to_f.round(2)
    @advance_total += d.advance_amount.to_f.round(2)
    @short_pay_total += d.wage_debit.to_f.round(2)
    @balance_total += d.balance.to_f.round(2)
    @sorted_data << {
                      department: "#{d.department.present? ? d.department.title : ""}: #{d.staff_raw_products.present? ? d.staff_raw_products_titles : ""}",
                      code: d.code,
                      name: "#{d.name} #{d.father}",
                      monthly_wage: "#{d.staff_salary_or_wage.to_f.round(2)}",
                      advance: d.advance_amount.to_f.round(2),
                      short_pay: d.wage_debit.to_f.round(2),
                      balance: d.balance.to_f.round(2),
                      monthly_wage_total: @monthly_wage,
                      advance_total: @advance_total,
                      short_pay_total: @short_pay_total,
                      balance_total: @balance_total
                    }
  end

  def export_file
    export_data('Staff')
  end

  def set_top_data_for_csv
    heading_of = 'Staff Details'
    heading_of = 'Salary Staff Details' if params[:salary_submit_csv].present?
    heading_of = 'Wage Staff Details' if params[:wage_submit_csv].present?
    @top_data = [
      ['--------------------------------------'],
      [heading_of],
      ['--------------------------------------'],
      ["Printing Date Time #{@time.strftime('%d')} / #{@time.strftime('%b')} / #{@time.strftime('%y')} / #{@time.strftime('at %I:%M%p')}"],
      ["Current User #{@current_user.name}"]
    ]
  end

  def set_edit_new_data
    @departments = Department.all
    @cities = City.all
    @countries = Country.all
    @raw_products = RawProduct.all
  end
end
