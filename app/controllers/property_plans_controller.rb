class PropertyPlansController < ApplicationController
  before_action :set_property_plan, only: [:show, :edit, :update, :destroy]
  before_action :set_property_installment, only: [:show]
  before_action :set_property_installment_edit, only: [:edit_property_installment, :update_installment]

  # GET /property_plans
  # GET /property_plans.json
  def index
    @customers=SysUser.where(:user_group=>['Customer','Supplier','Both','Salesman'])

    if params[:short_advance].present?
      @q = PropertyPlan.joins(:order).where(due_status:[nil, PropertyPlan.due_statuses["Unpaid"]]).where('due_date <= ?', Date.today).ransack(params[:q])
    else
      @q = PropertyPlan.joins(:order).where(due_status:[nil, PropertyPlan.due_statuses["Unpaid"]]).where('due_date <= ?', Date.today).ransack(params[:q])
    end
    @property_plans = @q.result
    @total_advance = @property_plans.sum(:advance)
    if params[:submit_pdf].present?
      print_pdf('properties', 'pdf.html','A4')
    end

    sys_users  = Order.joins(:property_plans).where('property_plans.id':@property_plans.pluck(:id)).pluck(:sys_user_id)
    @sys_users = SysUser.joins(:contact).where(id:sys_users)
    @home   = @sys_users.pluck('home').uniq
    @office = @sys_users.pluck('office').uniq
    @mobile = @sys_users.pluck('mobile').uniq
    @phone  = (@mobile+@office+@home).uniq.compact.reject(&:empty?).join(',')
    @property_plans = @property_plans.page(params[:page])


  end

  def property_installment

    @customers=SysUser.where(:user_group=>['Customer','Supplier','Both','Salesman'])
    if params[:short_advance].present?
      @q = PropertyInstallment.where(due_status:[nil, PropertyPlan.due_statuses["Unpaid"]]).ransack(params[:q])
    elsif params[:submit_pdf_bulk].present?
      @q = PropertyPlan.joins(:property_installments).includes(:property_installments).where('property_installments.due_status':[nil, PropertyPlan.due_statuses["Unpaid"]]).ransack('property_installments_due_date_lteq':params[:q][:due_date_lteq])
    else
      @q = PropertyInstallment.where(due_status:[nil, PropertyPlan.due_statuses["Unpaid"]]).ransack(params[:q])
    end

    @property_installments = @q.result
    @short_pay_total = @property_installments.sum(:installment_price)
    
    # @last_payment_total = @property_installments.sum('property_plan.order&.sys_user&.ledger_books.where('credit>0')&.last&.credit')
    sys_users   = Order.joins(property_plans: :property_installments).where('property_plans.id': @property_installments.pluck(:property_plan_id)).pluck(:sys_user_id).uniq
    #
    @sys_users  = SysUser.joins(:contact).where(id:sys_users)
    @home       = @sys_users.pluck('home').uniq
    @office     = @sys_users.pluck('office').uniq
    @mobile     = @sys_users.pluck('mobile').uniq
    @phone      = (@mobile+@office+@home).uniq.compact.reject(&:empty?).join(',')

    if params[:submit_pdf].present? or params[:submit_pdf_search].present?
      print_pdf('properties', 'pdf.html','A4')
    elsif params[:submit_pdf_bulk].present?
      @property_installments_count = @property_installments.group(:property_plan_id).count
      @property_installments_sum = @property_installments.group(:property_plan_id).sum(:installment_price)
      print_pdf('properties', 'pdf.html','A4')
    end

    @property_installments = @property_installments.page(params[:page])

  end

  def property_installment_bulk

    @customers=SysUser.where(:user_group=>['Customer','Supplier','Both','Salesman'])
    @q = PropertyPlan.joins(:property_installments).includes(:property_installments).where('property_installments.due_status':[nil, PropertyPlan.due_statuses["Unpaid"]]).ransack(params[:q])
    @property_installments = @q.result
    @property_installments_count = @property_installments.group(:property_plan_id).count
    @property_installments_sum = @property_installments.group(:property_plan_id).sum(:installment_price)

    @short_pay_total = @property_installments.sum(:installment_price)
    sys_users   = Order.joins(property_plans: :property_installments).where('property_plans.id': @property_installments.pluck(:property_plan_id)).pluck(:sys_user_id).uniq
    @sys_users  = SysUser.joins(:contact).where(id:sys_users)
    @home       = @sys_users.pluck('home').uniq
    @office     = @sys_users.pluck('office').uniq
    @mobile     = @sys_users.pluck('mobile').uniq
    @phone      = (@mobile+@office+@home).uniq.compact.reject(&:empty?).join(',')
    # @property_installments = @property_installments.page(params[:page])
    print_pdf('properties', 'pdf.html','A4')
  end

  # GET /property_plans/1
  # GET /property_plans/1.json
  def show
    if params[:page_size].present?
      print_pdf("Order Detail",'pdf.html','A3')
    else
      print_pdf("Order Detail",'pdf_styleless.html','A4',false,'Landscape')
    end
  end

  # GET /property_plans/new
  def new
    @property_plan = PropertyPlan.new
  end

  # GET /property_plans/1/edit
  def edit
  end
  def edit_property_installment
  end

  # POST /property_plans
  # POST /property_plans.json
  def create
    @property_plan = PropertyPlan.new(property_plan_params)

    respond_to do |format|
      if @property_plan.save
        save_installments
        format.html { redirect_to @property_plan, notice: 'Property plan was successfully created.' }
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
        format.html { redirect_to orders_path(sale:true), notice: 'Property plan was successfully updated.' }
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
        format.html { redirect_to orders_path(sale:true), notice: 'Property Installment was successfully updated.' }
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
      @property_installment = PropertyInstallment.find_by(id:params[:property_installment])
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
      :bank_detail
    )
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
end