class PropertyPlansController < ApplicationController
  before_action :check_access
  before_action :set_property_plan, only: %i[show edit update destroy]
  before_action :set_property_installment, only: [:show]
  before_action :set_property_installment_edit, only: %i[edit_property_installment update_installment]
  include PdfCsvGeneralMethod
  include PropertyPlansHelper

  # GET /property_plans
  # GET /property_plans.json
  def index
    @customers = SysUser.where(user_group: %w[Customer Supplier Both Salesman])
    @q = if params[:short_advance].present?
           PropertyPlan.joins(:order).where(due_status: [nil, PropertyPlan.due_statuses['Unpaid']]).where(
             'due_date <= ?', Date.today
           ).ransack(params[:q])
         else
           PropertyPlan.joins(:order).where(due_status: [nil, PropertyPlan.due_statuses['Unpaid']]).where(
             'due_date <= ?', Date.today
           ).ransack(params[:q])
         end
    @property_plans = @q.result
    @total_advance = @property_plans.sum(:advance)
    download_property_plans_csv_file if params[:csv].present?
    download_property_plans_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?

    sys_user_ids  = Order.joins(:property_plans).where('property_plans.id': @property_plans.pluck(:id)).pluck(:sys_user_id)
    @sys_users = SysUser.joins(:contact).where(id: sys_user_ids)
    @home   = @sys_users.pluck('home').uniq
    @office = @sys_users.pluck('office').uniq
    @mobile = @sys_users.pluck('mobile').uniq
    @phone  = (@mobile + @office + @home).uniq.compact.reject(&:empty?).join(',')
    @options_for_select = PropertyPlan.all
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @custom_pagination = @pos_setting.custom_pagination['property_plans'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['property_plans'].present?
    @property_plans = @property_plans.page(params[:page]).per(@custom_pagination)
  end

  def property_installment
    @customers = SysUser.where(user_group: %w[Customer Supplier Both Salesman])
    @products = Product.all
    @dealers = Staff.all
    property_plan_ids = PropertyPlan.ransack_with_installment_count(params)

    @q = PropertyPlan.joins(:property_installments, order: [:sys_user, order_items: :product])
                     .includes(:property_installments, order: [:sys_user, order_items: :product])
                     .where('property_installments.due_status': [nil, PropertyPlan.due_statuses['Unpaid']],
                            id: property_plan_ids)
                     .ransack(params[:q])

    @property_installments = @q.result.with_installment_amount_in_range(params[:installment_amount_from], params[:installment_amount_to])
    @installments_count = @property_installments.group('property_plans.id').count('property_installments.id')
    @short_pay_total = @property_installments.sum(:installment_price)

    # @last_payment_total = @property_installments.sum('property_plan.order&.sys_user&.ledger_books.where('credit>0')&.last&.credit')
    sys_users   = Order.joins(property_plans: :property_installments).where('property_plans.id': @property_installments.pluck(:property_plan_id)).pluck(:sys_user_id).uniq
    @sys_users  = SysUser.joins(:contact).where(id: sys_users)
    @home       = @sys_users.pluck('home').uniq
    @office     = @sys_users.pluck('office').uniq
    @mobile     = @sys_users.pluck('mobile').uniq
    @phone      = (@mobile + @office + @home).uniq.compact.reject(&:empty?).join(',')
    property_installment_pdf if params[:pdf].present?
    property_installment_csv if params[:csv].present?
    @property_installments = @property_installments.order('products.title ASC').page(params[:page])
  end

  def property_installment_bulk
    @customers = SysUser.where(user_group: %w[Customer Supplier Both Salesman])
    @q = PropertyPlan.joins(:property_installments).includes(:property_installments).where('property_installments.due_status': [
                                                                                             nil, PropertyPlan.due_statuses['Unpaid']
                                                                                           ]).ransack(params[:q])
    @property_installments = @q.result
    @property_installments_count = @property_installments.group(:property_plan_id).count
    @property_installments_sum = @property_installments.group(:property_plan_id).sum(:installment_price)

    @short_pay_total = @property_installments.sum(:installment_price)
    sys_users   = Order.joins(property_plans: :property_installments).where('property_plans.id': @property_installments.pluck(:property_plan_id)).pluck(:sys_user_id).uniq
    @sys_users  = SysUser.joins(:contact).where(id: sys_users)
    @home       = @sys_users.pluck('home').uniq
    @office     = @sys_users.pluck('office').uniq
    @mobile     = @sys_users.pluck('mobile').uniq
    @phone      = (@mobile + @office + @home).uniq.compact.reject(&:empty?).join(',')
    # @property_installments = @property_installments.page(params[:page])
    print_pdf('properties', 'pdf.html', 'A4')
  end

  # GET /property_plans/1
  # GET /property_plans/1.json
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /property_plans/new
  def new
    @property_plan = PropertyPlan.new
    @orders = Order.all
    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET /property_plans/1/edit
  def edit
    @orders = Order.all
    respond_to do |format|
      format.js
      format.html
    end
  end

  def edit_property_installment; end

  # POST /property_plans
  # POST /property_plans.json
  def create
    @property_plan = PropertyPlan.new(property_plan_params)
    respond_to do |format|
      if @property_plan.save
        save_installments
        format.html { redirect_to property_plans_path, notice: 'Property plan was successfully created.' }
        format.json { render :show, status: :created, location: @property_plan }
      else
        format.html { render :new }
        format.json { render json: @property_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /property_plans/1
  # PATCH/PUT /property_plans/1.json
  def update
    respond_to do |format|
      if @property_plan.update(property_plan_params)
        # save_installments
        format.html { redirect_to property_plans_path, notice: 'Property plan was successfully updated.' }
        format.json { render :show, status: :ok, location: @property_plan }
      else
        format.html { render :edit }
        format.json { render json: @property_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /property_plans/1
  # PATCH/PUT /property_plans/1.json
  def update_installment
    respond_to do |format|
      if @property_installment.update(property_installment_params)
        # save_installments
        format.html { redirect_to orders_path(sale: true), notice: 'Property Installment was successfully updated.' }
        format.json { render :show, status: :ok, location: @property_plan }
      else
        format.html { render :edit }
        format.json { render json: @property_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /property_plans/1
  # DELETE /property_plans/1.json
  def destroy
    @property_plan.destroy
    respond_to do |format|
      format.html { redirect_to property_plans_url, notice: 'Property plan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def save_installments
    installments_list = params[:property_plan][:installments_list]
    no_of_installments = property_plan_params[:no_of_installments].to_i
    (1..no_of_installments).each do |no_ins|
      property_installment = PropertyInstallment.find_or_initialize_by(
        property_plan_id: @property_plan.id,
        installment_no: no_ins
      )
      property_installment.installment_price = installments_list[no_ins.to_s].first
      property_installment.save!
    end

    @property_plan.property_installments.where(
      'installment_no > ?', no_of_installments
    ).delete_all
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_property_plan
    @property_plan = PropertyPlan.find(params[:id])
  end

  def set_property_installment
    @property_installment = PropertyInstallment.find_by(id: params[:property_installment])
  end

  def set_property_installment_edit
    @property_installment = PropertyInstallment.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def property_plan_params
    params.require(:property_plan).permit(:id,
                                          :property_type,
                                          :area_in_marla,
                                          :price_per_marla,
                                          :total_price,
                                          :payment_type,
                                          :payment_plan,
                                          :no_of_installments,
                                          :advance,
                                          :high_amount_installments,
                                          :total_high_amount,
                                          :created_at,
                                          :updated_at,
                                          :order_id,
                                          :last_instalment,
                                          :due_date,
                                          :due_status,
                                          :payment_method,
                                          :bank_detail)
  end

  def property_installment_params
    params.require(:property_installment).permit(
      :id,
      :property_plan_id,
      :installment_no,
      :installment_price,
      :high_price,
      :normal_price,
      :created_at,
      :updated_at,
      :due_date,
      :due_status,
      :payment_method,
      :bank_detail
    )
  end
  def download_property_plans_csv_file
    @property_plan= @q.result
    header_for_csv = %w[Id User Phone Plot Last_Payment Last_Payment_Date Advance Size Due_Date Dealer]
    data_for_csv = get_data_for_property_plan_csv
    generate_csv(data_for_csv, header_for_csv,
                 "Property-Plan-Total-#{@property_plan.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
  end

  def download_property_plans_pdf_file
    sort_data_according
    generate_pdf(@sorted_data.as_json, "Property-Plan-Total-#{@sorted_data.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}",
                 'pdf.html', 'A4', false, 'property_plans/index.pdf.erb')
  end

  def send_email_file
    sort_data_according
    EmailJob.perform_later(@sorted_data.as_json, 'property_plans/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "Property-Plan-Total-#{@sorted_data.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
    flash[:notice] = if params[:email_value].present?
                       "Email has been sent to #{params[:email_value]}"
                     else
                       "Email has been sent to #{current_user.email}"
                     end
    redirect_to property_plans_path
  end

  def sort_data_according
    @sorted_data = []
    @q.result.each do |d|
      @sorted_data << {
                        Id: d.id,
                        User: d.order&.sys_user&.name,
                        Phone:  d.order&.sys_user&.contact&.phone,
                        Plot: d.order&.order_items_names_and_quantity&.first&.first,
                        Last_Payment: d.order&.sys_user&.ledger_books.where('credit>0')&.last&.credit,
                        Last_Payment_Date: d.order&.sys_user&.ledger_books.where('credit>0')&.last&.created_at&.strftime("%d%b%y at %I:%M%p"),
                        Advance: d.advance,
                        Size: d.order&.order_items_names_and_quantity&.first[8].to_s + "-M" + d.order&.order_items_names_and_quantity&.first[9].to_s + "-sqr",
                        Due_Date: d.due_date.present? ? d.due_date.strftime("%d%b%y at %I:%M%p") : '',
                        Dealer: d&.order&.order_plot_dealer&.first&.staff&.name
                      }
    end
  end

  def export_file
    export_data('PropertyPlan')
  end

  def property_installment_pdf
    generate_pdf(@property_installments, "Installment-Plan-#{@property_installments.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}",
    'pdf.html', 'A4', false, 'property_plans/property_installment.pdf.erb')
  end

  def property_installment_csv
    header_for_csv = %w[Id User Phone Plot Size Last_Payment Last_Payment_Date Installment Due_Date Dealer]
    data = get_data_for_property_installment_csv
    generate_csv(data, header_for_csv,
                 "Property-Plan-Total-#{@property_installments.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
  end
end
