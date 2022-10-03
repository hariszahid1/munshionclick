class LogsController < ApplicationController

  # GET /accounts
  # GET /accounts.json
  def index

    @created_at_gteq = DateTime.now-5000
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @created_at_lteq = params[:q][:created_at_lteq]
    end
    @event = ["create", "update", "destroy"]
    @users = User.pluck(:id,:user_name).to_h
    @q = PaperTrail::Version.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    @logs = @q.result.page(params[:page])
    if params[:submit_pdf].present?
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      @logs = @q.result
      request.format = 'pdf'
      print_pdf('Activity Log From -'+@created_at_gteq.to_s+' to '+@created_at_lteq.to_s,'pdf.html','A4')
    end

    @tables = (ActiveRecord::Base.connection.tables.map do |model|
      model.capitalize.singularize.camelize
    end)
  end
  def logs_detail
    @created_at_gteq = DateTime.now-5000
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @created_at_lteq = params[:q][:created_at_lteq]
    end


    @q = PaperTrail::Version.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
    @logs = @q.result
    @logs = PaperTrail::Version.where('created_at BETWEEN ? AND ?', @created_at_gteq, @created_at_lteq).group(:item_type,:event).count(:id)
    @log_list = []
    single_list = ''
    @logs.each do |log|
      single_list = ''
      case log&.first&.first
      when "LedgerBook"
        single_list = 'UserLedgerBook'
      when "Order"
        single_list = 'Booking'
      when "OrderItem"
        single_list = 'BookingDetail'
      when "Payment"
        single_list = 'AccountPayment'
      when "Product"
        single_list = 'Plot'
      when "ProductCategory"
        single_list = 'PlotCategory'
      when "ProductSubCategory"
        single_list = 'PlotSubCategory'
      when "PurchaseSaleDetail"
        single_list = 'Installment'
      when "PurchaseSaleItem"
        single_list = 'InstallmentDetail'
      when "SysUser"
        single_list = 'User'
      when "Salary"
      when "SalaryDetail"
      when "ExpenseType"
      when "PosSetting"
      when "Product"
      when "User"
      when "ProductWarranty"
      when "ProductStock"
      when "PurchaseSaleDetail"
      else
        single_list = log&.first&.first
      end
      if single_list.present?
        @log_list<< [
          single_list&.capitalize,
          log&.first&.last&.capitalize,
          log&.last,
          log&.first&.first
        ]
      end
    end
    @logs = @log_list.sort
  end
  # GET /accounts/1
  # GET /accounts/1.json
  def show
    @created_at_gteq = DateTime.now-5000
    @created_at_lteq = DateTime.now
    @users = User.pluck(:id,:user_name).to_h
    if params[:id].present?
      @logs = PaperTrail::Version.where('created_at BETWEEN ? AND ?', @created_at_gteq, @created_at_lteq).where(id:params[:id]).order('id desc').ransack().result.page(params[:page])
    end
  end

end
