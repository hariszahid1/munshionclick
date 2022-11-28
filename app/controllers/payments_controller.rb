class PaymentsController < ApplicationController
	before_action :check_access
  before_action :set_payment, only: [:show, :edit, :update, :destroy, :confirmable_change]

  # GET /payments
  # GET /payments.json
  def index
    @start_date = Date.today.prev_occurring(:thursday)
    @end_date = DateTime.now
    if params[:q].present?
      @title = params[:q][:account_title_cont]
      @start_date = params[:q][:created_at_gteq]
      @end_date = params[:q][:created_at_lteq]
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @q = Payment.ransack(params[:q])
    else
      @q = Payment.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).ransack(params[:q])
    end
    if params[:submit_pdf_asc].present? || params[:asc_email].present? || params['2_submit_pdf_asc'].present?
      if @q.result.count > 0
        @q.sorts = ['id asc', 'created_at asc'] if @q.sorts.empty?
      end
    else
      if @q.result.count > 0
        @q.sorts = ['id desc', 'created_at desc'] if @q.sorts.empty?
      end
    end
    @accounts=Account.all
    @payment_all = @q.result

    if params[:submit_pdf].present? || params[:submit_pdf_asc].present? || params['1_submit_pdf'].present? || params['2_submit_pdf_asc'].present?
      request.format = 'pdf'
      @payments = @q.result
      @account = Account.where(id: @payments.pluck(:account_id)).pluck(:title).join(',')
    else
      @payments = @q.result.page(params[:page]).per(50)
    #  @t_dabit=@payments.sum(:debit)
    end

    if params[:asc_email].present? or  params[:desc_email].present? and @q.result.count > 0
      @pdf_index=render_to_string(:pdf => "Asc - Payment",:template => 'payments/index.pdf.erb',:filename => 'Asc - Payments')
    end

    @t_dabit=@payment_all.select('SUM(debit) as sum_debit','SUM(credit) as sum_credit','SUM(credit)-SUM(debit) as mean_sum')
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "DayBook+Payment-History",
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

    if params[:desc_email].present? or params[:asc_email].present? and @q.result.count > 0
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - Payment"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_index,'Payment']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to payments_path
    end
  end

  def confirm_index
    @start_date = Date.today
    @end_date = DateTime.now
    if params[:q].present?
      @title = params[:q][:account_title_cont]
      @start_date = params[:q][:created_at_gteq]
      @end_date = params[:q][:created_at_lteq]
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @q = Payment.where(confirmable: nil).ransack(params[:q])
    else
      @q = Payment.where(confirmable: nil).where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).ransack(params[:q])
    end
    if params[:submit_pdf_asc].present?
      if @q.result.count > 0
        @q.sorts = ['id asc', 'created_at asc'] if @q.sorts.empty?
      end
    else
      if @q.result.count > 0
        @q.sorts = ['id desc', 'created_at desc'] if @q.sorts.empty?
      end
    end
    @accounts=Account.all
    @payment_all = @q.result()

    if params[:submit_pdf].present? || params[:submit_pdf_asc].present?
      request.format = 'pdf'
      @payments = @q.result(distinct: true)
    else
      @payments = @q.result(distinct: true).page(params[:page]).per(50)
    end
    @t_dabit=@payment_all.select('SUM(debit) as sum_debit','SUM(credit) as sum_credit','SUM(credit)-SUM(debit) as mean_sum')
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Confirmable Payments",
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

  def confirmable_change
    respond_to do |format|
      if @payment.update(confirmable:1,confirmed_by: current_user.id,confirmed_at:DateTime.now)
        format.html { redirect_to confirm_index_path('q[created_at_lteq]':params[:created_at_lteq],'q[created_at_gteq]':params[:created_at_gteq]), notice: 'Payment Confirmable successfully updated.' }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirmable_change_bulk
    if params[:created_at_gteq].present?
      @start_date = params[:created_at_gteq]
      @end_date = params[:created_at_lteq]
      respond_to do |format|
        if Payment.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).update_all(confirmable: 1, confirmed_by: current_user.id, confirmed_at: DateTime.now)
          format.html { redirect_to confirm_index_path('q[created_at_lteq]':params[:created_at_lteq],'q[created_at_gteq]':params[:created_at_gteq]), notice: 'Payment Confirmable successfully updated.' }
          format.json { render :show, status: :ok, location: @payment }
        else
          format.html { render :edit }
          format.json { render json: @payment.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
    @q = Payment.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = ['id desc', 'created_at desc'] if @q.sorts.empty?
    end
    @accounts=Account.all
    @payments = @q.result

  end

  # GET /payments/new
  def new
    @payment = Payment.new
    @accounts=Account.all
    @account=current_user.user_account
  end

  # GET /payments/1/edit
  def edit
    @accounts=Account.all
  end

  # POST /payments
  # POST /payments.json
  def create
    @payment = Payment.new(payment_params)
    @payment.status = ''
    if payment_params[:status].present?
      @payment_debit = Payment.new(payment_params)
      @payment_debit.account_id = @payment_debit.status
      @payment_debit.status = ''
      @payment_debit.credit = nil
      @payment_debit.debit = @payment.credit
      @payment_debit.comment = @payment_debit.account.title+" Transfer "+@payment.credit.to_s+" To "+@payment.account.title+" </> "+@payment.comment
      @payment.comment = @payment.account.title+" Received "+@payment.credit.to_s+" From "+@payment_debit.account.title+" </> "+@payment.comment
      @payment_debit.save!
    end
    @accounts = Account.all
    respond_to do |format|
      if @payment.save
				AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@payment.account_id)
        format.html { redirect_to payments_path, notice: 'Payment was successfully Transfer.' }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1
  # PATCH/PUT /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@payment.account_id)
        format.html { redirect_to payments_path, notice: 'Payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment.destroy!
    # credit = @payment.credit.to_f-@payment.debit.to_f
    # @payment.update(debit:0,amount:0,comment: "Destory Payment/Advance")
    # if @payment.account.present?
    #   @payment.account.amount = (@payment.account.amount.to_f - credit)
    #   @payment.account.save!
    # end
		AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@payment.account_id)
    respond_to do |format|
      format.html { redirect_to payments_url, notice: 'Payment was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end
  def transfer
    @payment = Payment.new
    @accounts = Account.all
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.require(:payment).permit(:debit, :credit, :paymentable_id, :paymentable_type, :comment,:account_id,:amount, :status, :created_at)
    end
end
