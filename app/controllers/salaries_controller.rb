class SalariesController < ApplicationController
  before_action :set_salary, only: [:show, :edit, :update, :destroy, :show_advance, :edit_advance]
  before_action :check_access

  # GET /salaries
  # GET /salaries.json
  def index
    @departments = Department.all
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @paid_to = params[:q][:paid_to_eq]
      @payment_type = params[:q][:payment_type_eq]
      @id = params[:q][:staff_id_eq]
      @department=params[:q][:staff_department_id_eq]
    end
    @salary_searchs=Staff.all
    @q = Salary.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    @salaries = @q.result.page(params[:page])
    if params[:submit_pdf].present?
      request.format = 'pdf'
    end
    @pos_setting=PosSetting.first
    respond_to do |format|
      format.html
      format.pdf do
        @salaries = @q.result
        render pdf: "Day-Out",
        layout: 'pdf.html',
        page_size: 'A4',
        margin_top: '0',
        margin_right: '0',
        margin_bottom: '0',
        margin_left: '0',
        footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
          right: '[page] of [topage]'},
        encoding: "UTF-8",
        show_as_html: false
      end
    end
  end

  # GET /salaries/1
  # GET /salaries/1.json
  def show
    request.format = 'pdf'
    print_pdf("Orders Detail",'pdf.html','A4')
  end

  # GET /salaries/1
  # GET /salaries/1.json
  def show_advance
  end
  def show_loan
  end

  # GET /salaries/new
  def new
    @staffs_list = activated_list("Staff")
    @salary = Salary.new(payment_type: :Salary)
    @accounts=Account.all
    @account=current_user.user_account
  end

  def advance
    @staffs_list = activated_list("Staff")
    @salary = Salary.new(payment_type: :Advance)
    @accounts=Account.all
    @account=current_user.user_account
  end

  def loan
    @staffs_list = activated_list("Staff")
    @salary = Salary.new(payment_type: :Loan)
    @accounts=Account.all
    @account=current_user.user_account
  end

  def advance_all
    @departments = Department.all
    if params[:q].present?
    @q = Staff.ransack(params[:q])
    else
      @q = Staff.where(department_id: @departments.first(3)).ransack()
    end
    if @q.result.count > 0
      @q.sorts = 'name asc' if @q.sorts.empty?
    end
    @staffs_list = @q.result(distinct: true)
    @salary = Salary.new(payment_type: :Advance)
    @accounts=Account.all
    @account=current_user.user_account
  end
  # GET /salaries/1/edit
  def edit
    @staffs_list = activated_list("Staff")
    @accounts=Account.all
  end

  # GET /salaries/1/edit
  def edit_advance
    @staffs_list = activated_list("Staff")
    @accounts=Account.all
  end
  # POST /salaries
  def edit_loan
    @staffs_list = activated_list("Staff")
    @accounts=Account.all
  end
  # POST /salaries.json
  def create
    @salary = Salary.new(salary_params)
    @salary.balance = @salary.balance.to_f - (@salary.advance.to_f+@salary.paid_salary.to_f)
    @salary.total_balance = @salary.total_balance.to_f - (@salary.advance.to_f+@salary.paid_salary.to_f)
    respond_to do |format|
      if @salary.save
        PaymentBalanceJob.set(wait: 1.minutes).perform_later(current_user.superAdmin.company_type)
        if @salary.payment_type=="Advance"
          @paid_to_month=@salary.created_at.month
          @paid_to_year=@salary.created_at.year
          advance=Salary.where("extract(month from created_at) = ? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).where(:staff_id=>@salary.staff_id).sum(:advance)
          Staff.where(:id=>@salary.staff_id).update(:advance_amount=>advance)
          if params[:commit]=="Save with Print"
            redirect_url_sal = @salary
          else
            redirect_url_sal = salaries_path
          end
          format.html { redirect_to redirect_url_sal, notice: @salary.payment_type+' was successfully created.' }
          format.js   { }
        elsif @salary.payment_type=="Loan"
          @paid_to_month=@salary.created_at.month
          @paid_to_year=@salary.created_at.year
          advance=Salary.where("extract(month from created_at) = ? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).where(:staff_id=>@salary.staff_id).sum(:advance)
          Staff.where(:id=>@salary.staff_id).update(:advance_amount=>advance)
          format.html { redirect_to salaries_path, notice: @salary.payment_type+' was successfully created.' }
          format.js   { }
        else
          format.html { redirect_to staffs_path, notice: @salary.payment_type+' was successfully created.' }
        end
        format.json { render :show, status: :created, location: @salary }
      else
        @staffs_list = activated_list("Staff")
        @salary = Salary.new(payment_type: :Salary)
        @accounts=Account.all
        format.html { render :new }
        format.json { render json: @salary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /salaries/1
  # PATCH/PUT /salaries/1.json
  def update
    respond_to do |format|
      if @salary.update(salary_params)
        if @salary.payment_type=="Advance"
          @paid_to_month=@salary.created_at.month
          @paid_to_year=@salary.created_at.year
          advance=Salary.where("extract(month from created_at) = ? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).where(:staff_id=>@salary.staff_id).sum(:advance)
          Staff.where(id:@salary.staff_id).update(advance_amount:advance)
        end
        if @salary.staff_ledger_book.present?
          SalaryDetailJob.perform_later(current_user.superAdmin.company_type,@salary.staff_id)
          AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@salary.account_id)
        end
        format.html { redirect_to salaries_path, notice: @salary.payment_type+' was successfully updated.' }
        format.json { render :show, status: :ok, location: @salary }
      else
        @staffs_list = activated_list("Staff")
        @salary = Salary.new(payment_type: :Salary)
        @accounts=Account.all

        format.html { render :edit }
        format.json { render json: @salary.errors, status: :unprocessable_entity }
      end
    end
  end

  def work_detail
    @departments=Department.all
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @paid_to = params[:q][:paid_to_eq]
      @payment_type = params[:q][:payment_type_eq]
      @q = Salary.ransack(params[:q])
      @p = SalaryDetail.ransack(params[:q])
      @staff=params[:q][:staff_id_eq]
      @staff_detail=Staff.find(params[:q][:staff_id_eq])
    else
      @q = Salary.where(staff_id: Staff.first.id).ransack(params[:q])
      @p = SalaryDetail.where(staff_id: Staff.first.id).ransack(params[:q])
      @staff=Staff.first.id
      @staff_detail=Staff.where(department_id: @departments.first.id).first
    end
    puts "*******************************************"
    puts @staff
    puts "*******************************************"
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    @salary_searchs=Staff.all
    @salaries = @q.result(distinct: true)
    if @p.result.count > 0
      @p.sorts = 'id desc' if @p.sorts.empty?
    end
    @salary_details = @p.result(distinct: true)
    if params[:submit_pdf].present?
      request.format = 'pdf'
    end
    @pos_setting=PosSetting.first
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Day-Out",
        layout: 'pdf.html',
        page_size: 'A4',
        margin_top: '0',
        margin_right: '0',
        margin_bottom: '0',
        margin_left: '0',
        footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
          right: '[page] of [topage]'},
        encoding: "UTF-8"
      end
    end
  end
  # DELETE /salaries/1
  # DELETE /salaries/1.json
  def destroy
    # @salary.payment.destroy_all
    @salary.destroy
    if @salary.payment_type=="Advance"
      @paid_to_month=@salary.created_at.month
      @paid_to_year=@salary.created_at.year
      advance=Salary.where("extract(month from created_at) = ? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).where(:staff_id=>@salary.staff_id).sum(:advance)
      Staff.where(:id=>@salary.staff_id).update(:advance_amount=>advance)
    end
    SalaryDetailJob.perform_later(current_user.superAdmin.company_type,@salary.staff_id)
    AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@salary.account_id)
    respond_to do |format|
      format.html { redirect_to salaries_url, notice: 'Record was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  def analytics
    type = params[:type]
    case type
    when 'weekly'
      date_limit = DateTime.current.all_week
    when 'monthly'
      date_limit = DateTime.current.all_month
    when 'yearly'
      date_limit = DateTime.current.all_year
    else
      date_limit = DateTime.current.all_day
    end

    if params[:q].present?
      params[:q][:created_at_gteq] = params[:q][:created_at_gteq].to_date.beginning_of_day if params[:q][:created_at_gteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @q = Salary.joins(staff: :department).includes(staff: :department).ransack(params[:q])
    else
      @q = Salary.joins(staff: :department).includes(staff: :department).where(created_at: date_limit).ransack(params[:q])
    end
    @salaries_paid_staff = @q.result.group('staffs.name').sum(:total_balance)
    @advance_paid_staff = @q.result.group('staffs.name').sum(:advance)
    @salaries_paid_department = @q.result.group('departments.title').sum(:total_balance)
    @advance_paid_department = @q.result.group('departments.title').sum(:advance)
    @salaries_date_paid = @q.result.group("date(salaries.created_at)").sum(:total_balance)
    @advance_date_paid = @q.result.group("date(salaries.created_at)").sum(:advance)
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_salary
      @salary = Salary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def salary_params
      params.require(:salary).permit(:payment_type, :paid_to, :paid_salary, :advance, :leaves_in_month, :staff_id, :created_at, :updated_at, :account_id, :balance, :total_balance,:comment)
    end

    def activated_list(model_name)
      model_name.constantize.where(terminated: false, deleted: false)
    end
end

# staff_ledger_books = StaffLedgerBook.joins(:staff).where(staff_id: @salary.staff_id).where('credit>0 or debit>0').order('staffs.name asc', 'staff_ledger_books.created_at desc')
# debit_credit_balance = staff_ledger_books.select('SUM(debit) as sum_debit','SUM(credit) as sum_credit','SUM(credit)-SUM(debit) as mean_sum').first
# balance = debit_credit_balance.mean_sum
# staff_ledger_books = staff_ledger_books.first(500)
# staff_ledger_books.each do |lb|
#   if lb.balance!=balance
#     lb.balance=balance
#     lb.save!
#   end
#   balance=balance.to_f+(lb.debit.to_f-lb.credit.to_f)
# end
