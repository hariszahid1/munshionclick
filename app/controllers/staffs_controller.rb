class StaffsController < ApplicationController
	include StaffCsvMethods
  before_action :set_staff, only: [:show, :edit, :update, :destroy, :salary_info, :salary_wage_rate_info]

  # GET /staffs
  # GET /staffs.json
  def index
    @departments=Department.all
    @q = Staff.where(deleted: false).ransack(params[:q])
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
    if params[:submit_pdf]
			print_pdf('staff_details','pdf.html','A4')  #pdf's
    elsif params[:salary_submit_pdf]
			print_pdf('salary_staff_details','salary_staff.pdf','A4',true)
    elsif params[:wage_submit_pdf]
			print_pdf('wage_staff_details','wage_staff.pdf','A4')
		elsif params[:submit_csv]  #csv's
			csv_data=staff_details_csv
			createCSV("staff_details",csv_data)
		elsif params[:salary_submit_csv]
			csv_data=salary_staff_details_csv
			createCSV("salary_staff_details",csv_data)
		elsif params[:wage_submit_csv]
			csv_data=wage_staff_details_csv
			createCSV("wage_staff_details",csv_data)
    end
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

    respond_to do |format|
      format.js
    end
  end

  # GET /staffs/new
  def new
    @staff = Staff.new
    @departments=Department.all
    @raw_products = RawProduct.all
    @departments=Department.all
  end

  # GET /staffs/1/edit
  def edit
    @departments=Department.all
    @raw_products = RawProduct.all

    respond_to do |format|
      format.js
    end
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
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_staff
      @staff = Staff.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def staff_params
      params.require(:staff).permit(:code, :name, :father, :education, :gender, :phone, :address, :cnic, :date_of_joining, :date_of_leaving, :yearly_increment,
                                    :monthly_salary, :school_branch_id, :wage_rate, :balance, :staff_department, :department_id, :staff_type, :wage_debit,
                                     :raw_product_quantity, :profile_image, :staff_raw_products_attributes => [:id, :staff_id, :raw_product_id, :_destroy])
    end

		def createCSV(csv_name,csv_data)
			request.format = 'csv'
			respond_to do |format|
			format.html
			format.csv { send_data csv_data, filename: "#{csv_name} - #{Date.today}.csv" }
			end
		end

end
