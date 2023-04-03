class GatesController < ApplicationController
  before_action :set_gate, only: [:show, :edit, :update, :destroy]

  # GET /gates
  # GET /gates.json
  def index
    @products = Product.all
    @pather_from=DateTime.now-30
    @pather_to=DateTime.now
    @kharkar_from=DateTime.now-30
    @kharkar_to=DateTime.now
    @bhari_from=DateTime.now-30
    @bhari_to=DateTime.now
    @jalai_from=DateTime.now-30
    @jalai_to=DateTime.now
    @nakasi_from=DateTime.now-30
    @nakasi_to=DateTime.now
    @purchase_from=DateTime.now-30
    @purchase_to=DateTime.now
    @sale_from=DateTime.now-30
    @sale_to=DateTime.now
    @expense_from=DateTime.now-30
    @expense_to=DateTime.now
    @salary_from=DateTime.now-30
    @salary_to=DateTime.now
    @pather_date=((@pather_to-@pather_from)).floor
    @kharkar_date=((@kharkar_to-@kharkar_from)).floor
    @bhari_date=((@bhari_to-@bhari_from)).floor
    @jalai_date=((@jalai_to-@jalai_from)).floor
    @nakasi_date=((@nakasi_to-@nakasi_from)).floor
    @purchase_date=((@purchase_to-@purchase_from)).floor
    @expense_date=((@expense_to-@expense_from)).floor
    @salary_date=((@salary_to-@salary_from)).floor
    @full_production_date=((@nakasi_to-@pather_from)).floor
    if params[:q].present?
      if params[:q][:id_eq].present?
        gate=Gate.find(params[:q][:id_eq])
        params[:q][:id_eq]=params[:q][:id_eq]
        @pather_from=params[:q][:pather_from_gteq]=gate.pather_from
        @pather_to=params[:q][:pather_to_lteq]=gate.pather_to
        @kharkar_from=params[:q][:kharkar_from_gteq]=gate.kharkar_from
        @kharkar_to=params[:q][:kharkar_to_lteq]=gate.kharkar_to
        @bhari_from=params[:q][:bhari_from_gteq]=gate.bhari_from
        @bhari_to=params[:q][:bhari_to_lteq]=gate.bhari_to
        @jalai_from=params[:q][:jalai_from_gteq]=gate.jalai_from
        @jalai_to=params[:q][:jalai_to_lteq]=gate.jalai_to
        @nakasi_from=params[:q][:nakasi_from_gteq]=gate.nakasi_from
        @nakasi_to=params[:q][:nakasi_to_lteq]=gate.nakasi_to
        @sale_from=params[:q][:sale_from_gteq]=gate.sale_from
        @sale_to=params[:q][:sale_to_lteq]=gate.sale_to
        @expense_from=params[:q][:expense_from_gteq]=gate.expense_from
        @expense_to=params[:q][:expense_to_lteq]=gate.expense_to
        @salary_from=params[:q][:salary_from_gteq]=gate.salary_from
        @salary_to=params[:q][:salary_to_lteq]=gate.salary_to
        @purchase_from=params[:q][:purchase_from_gteq]=gate.purchase_from
        @purchase_to=params[:q][:purchase_to_lteq]=gate.purchase_to
        @pather_date=((@pather_to-@pather_from)/1.day).floor
        @kharkar_date=((@kharkar_to-@kharkar_from)/1.day).floor
        @bhari_date=((@bhari_to-@bhari_from)/1.day).floor
        @jalai_date=((@jalai_to-@jalai_from)/1.day).floor
        @nakasi_date=((@nakasi_to-@nakasi_from)/1.day).floor
        @purchase_date=((@purchase_to-@purchase_from)/1.day).floor
        @sale_date=((@sale_to-@sale_from)/1.day).floor
        @full_production_date=((@nakasi_to-@pather_from)/1.day).floor
        @expense_date=((@expense_to-@expense_from)/1.day).floor
        @salary_date=((@salary_to-@salary_from)/1.day).floor
      else
        @pather_from=params[:q][:pather_from_gteq].to_date if params[:q][:pather_from_gteq].present?
        @pather_to=params[:q][:pather_to_lteq].to_date if params[:q][:pather_to_lteq].present?
        @kharkar_from=params[:q][:kharkar_from_gteq].to_date if params[:q][:kharkar_from_gteq].present?
        @kharkar_to=params[:q][:kharkar_to_lteq].to_date if params[:q][:kharkar_to_lteq].present?
        @bhari_from=params[:q][:bhari_from_gteq].to_date if params[:q][:bhari_from_gteq].present?
        @bhari_to=params[:q][:bhari_to_lteq].to_date if params[:q][:bhari_to_lteq].present?
        @jalai_from=params[:q][:jalai_from_gteq].to_date if params[:q][:jalai_from_gteq].present?
        @jalai_to=params[:q][:jalai_to_lteq].to_date if params[:q][:jalai_to_lteq].present?
        @nakasi_from=params[:q][:nakasi_from_gteq].to_date if params[:q][:nakasi_from_gteq].present?
        @nakasi_to=params[:q][:nakasi_to_lteq].to_date if params[:q][:nakasi_to_lteq].present?
        @expense_from=params[:q][:expense_from_gteq].to_date if params[:q][:expense_from_gteq].present?
        @expense_to=params[:q][:expense_to_lteq].to_date if params[:q][:expense_to_lteq].present?
        @salary_from=params[:q][:salary_from_gteq].to_date if params[:q][:salary_from_gteq].present?
        @salary_to=params[:q][:salary_to_lteq].to_date if params[:q][:salary_to_lteq].present?
        @pather_date=((@pather_to-@pather_from)).floor
        @kharkar_date=((@kharkar_to-@kharkar_from)).floor
        @bhari_date=((@bhari_to-@bhari_from)).floor
        @jalai_date=((@jalai_to-@jalai_from)).floor
        @nakasi_date=((@nakasi_to-@nakasi_from)).floor
        @purchase_date=((@purchase_to-@purchase_from)).floor
        @sale_date=((@sale_to-@sale_from)).floor
        @expense_date=((@expense_to-@expense_from)).floor
        @salary_date=((@salary_to-@salary_from)).floor
        @full_production_date=((@nakasi_to-@pather_from)).floor
      end
      @departments=Department.all
      @q = DailyBook.where(book_date: @pather_from.beginning_of_day..@pather_to.end_of_day,department_id: @departments.first.id).ransack()
      @k = DailyBook.where(created_at: @kharkar_from.beginning_of_day..@kharkar_to.end_of_day,department_id: @departments.second.id).ransack()
      @bhari_bricks_quantity = ProductionBlock.where(date: @bhari_from.beginning_of_day..@bhari_to.end_of_day,status:"bhari").sum(:bricks_quantity)
      @bhari_tiles_quantity = ProductionBlock.where(date: @bhari_from.beginning_of_day..@bhari_to.end_of_day,status:"bhari").sum(:tiles_quantity)
      @j = ProductionCycle.where(start_date: @jalai_from.beginning_of_day..@jalai_to.end_of_day,status:"jalai").ransack()
      @n = DailyBook.where(created_at: @nakasi_from.to_date.beginning_of_day..@nakasi_to.to_date.end_of_day,department_id: @departments.third.id).ransack()
      @daily_books = @q.result
      @khakar_daily_books = @k.result
      @jalai_production_cycles = @j.result
      @nkasi_production_cycles = @n.result
      @expenses_with_type=ExpenseEntry.joins(:expense_type).where.not(expense_type_id:29).where(created_at: @expense_from.beginning_of_day..@expense_to.end_of_day).group('expense_types.title').sum(:amount)
      @expenses_total=ExpenseEntry.joins(:expense_type).where.not(expense_type_id:29).where(created_at: @expense_from.beginning_of_day..@expense_to.end_of_day).sum(:amount)
      @salary_amount = SalaryDetail.joins(staff: :department).where.not(wage_rate:nil).where.not('staffs.department_id':[1,2,3,4]).where(created_at: @salary_from.beginning_of_day..@salary_to.end_of_day).group('departments.title').sum(:amount)
      @purchase = PurchaseSaleItem.joins(:item).where.not('items.optimal':1).where(created_at: @purchase_from.beginning_of_day..@purchase_to.end_of_day).group(:title).sum(:total_cost_price)
      @purchase_quantity = PurchaseSaleItem.joins(:item).where.not('items.optimal':1).where(created_at: @purchase_from.beginning_of_day..@purchase_to.end_of_day).group(:title).sum(:quantity)
      @sale = PurchaseSaleItem.joins(:product).where(created_at: @sale_from.beginning_of_day..@sale_to.end_of_day).group(:title).sum(:total_sale_price)
      @sale_quantity = PurchaseSaleItem.joins(:product).where(created_at: @sale_from.beginning_of_day..@sale_to.end_of_day).group(:title).sum(:quantity)
      @pre_stock = ProductStock.where(created_at: (@nakasi_from-1).beginning_of_day..(@nakasi_from-1).end_of_day)
      @remain_stock = ProductStock.where(created_at: (@nakasi_to).beginning_of_day..(@nakasi_to).end_of_day)
    end
    @q = Gate.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    @gates = @q.result(distinct: true).page(params[:page])
    if params[:submit_pdf_a4].present?
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      @expenses = @q.result
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          @pos_setting=PosSetting.first
          render pdf: "Day-Out",
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

  # GET /gates/1
  # GET /gates/1.json
  def show
  end

  # GET /gates/new
  def new
    @gate = Gate.new
  end

  # GET /gates/1/edit
  def edit
  end

  # POST /gates
  # POST /gates.json
  def create
    @gate = Gate.new(gate_params)

    respond_to do |format|
      if @gate.save
        format.html { redirect_to gates_url, notice: 'Gate was successfully created.' }
        format.json { render :show, status: :created, location: @gate }
      else
        format.html { render :new }
        format.json { render json: @gate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gates/1
  # PATCH/PUT /gates/1.json
  def update
    respond_to do |format|
      if @gate.update(gate_params)
        format.html { redirect_to gates_url, notice: 'Gate was successfully updated.' }
        format.json { render :show, status: :ok, location: @gate }
      else
        format.html { render :edit }
        format.json { render json: @gate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gates/1
  # DELETE /gates/1.json
  def destroy
    @gate.destroy
    respond_to do |format|
      format.html { redirect_to gates_url, notice: 'Gate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gate
      @gate = Gate.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def gate_params
      params.require(:gate).permit(:pather_from, :pather_to, :kharkar_from, :kharkar_to, :bhari_from, :bhari_to, :jalai_from, :jalai_to, :nakasi_from, :nakasi_to, :purchase_from, :purchase_to, :sale_from, :sale_to, :expense_from, :expense_to, :salary_from, :salary_to, :comment)
    end
end
