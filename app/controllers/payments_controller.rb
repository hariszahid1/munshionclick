class PaymentsController < ApplicationController
	before_action :check_access
  before_action :set_payment, only: [:show, :edit, :update, :destroy, :confirmable_change]

  # GET /payments
  # GET /payments.json
  def index
    @account_ids = Account.where(id: current_user&.extra_settings.try(:[], 'account_ids'))
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
      if @account_ids.present?
        @payments = @q.result.where(account_id: @account_ids).page(params[:page]).per(50)
      else
        @payments = @q.result.page(params[:page]).per(50)
      end
    #  @t_dabit=@payments.sum(:debit)
    end
  
    if params.dig(:q, :account_id_in).present? && params.dig(:q, :created_at_gteq).present? && @q.result.blank?
      acc_id = params[:q][:account_id_in]
      acc_date = params[:q][:created_at_gteq]
      @total_b = Payment.where('created_at < ?', acc_date).where(account_id: acc_id).last&.amount.to_f
    end
    if params[:asc_email].present? or  params[:desc_email].present? and @q.result.count > 0
      @pdf_index=render_to_string(:pdf => "Asc - Payment",:template => 'payments/index.pdf.erb',:filename => 'Asc - Payments')
    end
    @t_dabit=@payment_all.select('SUM(debit) as sum_debit','SUM(credit) as sum_credit','SUM(credit)-SUM(debit) as mean_sum')
    pdfName = '[' + Account.where(id: @q.result.pluck(:account_id)).pluck(:title).join(' ') + ']'

    if params[:payment_asc_op].present?
      @payments = @q.result.reorder('id asc', 'created_at asc')
      print_pdf("ASC-OP-Payment -" + @start_date.to_s + ' to ' + @end_date.to_s, 'pdf.html', 'A4')
    elsif params[:payment_desc_op]
      @payments = @q.result.reorder('id desc', 'created_at desc')
      print_pdf("DESC-OP-Payment -" + @start_date.to_s + ' to ' + @end_date.to_s, 'pdf.html', 'A4')
    else
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "#{pdfName}-DayBook+Payment-History -" + @start_date.to_s + ' to ' + @end_date.to_s,
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

    if params[:desc_email].present? or params[:asc_email].present? and @q.result.count > 0
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - Payment"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_index,'Payment']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to payments_path
    end

    @today_debit_payment = @q.result.where(created_at: Time.current.all_day).sum(:debit).to_f
    @today_credit_payment = @q.result.where(created_at: Time.current.all_day).sum(:credit).to_f
    @yesterday_debit_payment = @q.result.where(created_at: 1.day.ago.all_day).sum(:debit).to_f
    @yesterday_credit_payment = @q.result.where(created_at: 1.day.ago.all_day).sum(:credit).to_f
    @percentage_debit_payment = ((@today_debit_payment - @yesterday_debit_payment) / (@yesterday_debit_payment.to_f.positive? ? @yesterday_debit_payment.to_f : 1 ) ).round(2)
    @percentage_credit_payment = ((@today_credit_payment - @yesterday_credit_payment) / (@yesterday_credit_payment.to_f.positive? ? @yesterday_credit_payment.to_f : 1 )).round(2)
    @payment_debit_count = @q.result.where(created_at: Time.current.all_day).count(:debit)
    @payment_credit_count = @q.result.where(created_at: Time.current.all_day).count(:credit)
    @monthly_debit_payment = @q.result.where(created_at: Time.current.all_month).sum(:debit).to_f
    @monthly_credit_payment = @q.result.where(created_at: Time.current.all_month).sum(:credit).to_f


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
    @q = PaperTrail::Version.where(item_type:"Payment").order('created_at desc').ransack(params[:q])
    @payment_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end

  def account_payment
    # Extract common expressions into variables
    @account_id = params.dig(:q, :account_id_eq)

    if params.dig(:q, :created_at_gteq).present?
      @start_date = params[:q][:created_at_gteq].to_date.beginning_of_day
      @end_date = params[:q][:created_at_lteq].to_date.end_of_day
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day
      params[:q][:created_at_gteq] = params[:q][:created_at_gteq].to_date.beginning_of_day
    else
      @start_date = Time.now.beginning_of_month
      @end_date = Time.now.end_of_day
    end
    @q = Payment.order(created_at: :desc).ransack(params[:q])
    @monthly_data = Payment.where(created_at: Time.now.beginning_of_month..DateTime.now.end_of_day, account_id: @account_id)
    @previous_credit = Payment.order(created_at: :desc).where(account_id: @account_id).where.not(credit: nil).first&.credit&.round(2).to_f
    @t_dabit = @q.result.select('SUM(debit) as sum_debit', 'SUM(credit) as sum_credit', '(SUM(credit) - SUM(debit)) as mean_sum')
    @account = Account.find_by(id: @account_id)
    @payments = @q.result.page(params[:page]).per(25)
    @starting_number = 1 + 25 * ([params[:page].to_i, 1].max - 1)
    return unless params[:pdf].present?

    @payments = @q.result
    print_pdf('expense-sheet', 'pdf.html', 'A4')
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
