class ItemsController < ApplicationController
  before_action :check_access
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.json
  def index
    @q = Item.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:title_or_code_cont]
      @code = params[:q][:code_eq]
    end
    @items = @q.result(distinct: true).page(params[:page])
    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @items=@q.result(distinct: true)
      print_pdf('Raw Material List', 'pdf.html','A4')
    end
    total_count_for_index
  end

  # GET /items/1
  # GET /items/1.json
  def show
  end

  # GET /items/new
  def new
    @item = Item.new
    @item_types=ItemType.all
  end

  # GET /items/1/edit
  def edit
    @item_types=ItemType.all
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)

    respond_to do |format|
      if @item.save
        format.js
        format.html { redirect_to items_url, notice: 'Item was successfully created.' }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to items_url, notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  def analytics
    type = params[:type]
    date_limit = case type
                 when 'daily'
                  DateTime.current.all_day
                 when 'weekly'
                   DateTime.current.all_week
                 when 'monthly'
                   DateTime.current.all_month
                 when 'yearly'
                   DateTime.current.all_year
                 else
                   DateTime.current.all_day
                 end

    if params[:q].present?
      if params[:q][:created_at_gteq].present?
        params[:q][:created_at_gteq] =
          params[:q][:created_at_gteq].to_date.beginning_of_day
      end
      if params[:q][:created_at_lteq].present?
        params[:q][:created_at_lteq] =
          params[:q][:created_at_lteq].to_date.end_of_day
      end
     
      @q = Item.joins(:item_type).ransack(params[:q])
    else
      @q = Item.joins(:item_type).where(created_at: date_limit).ransack
    end

    @item_type_count = @q.result.group('item_types.title').count
    @the_item_cost = @q.result.group('item_types.title').sum(:cost)
    @the_item_sale = @q.result.group('item_types.title').sum(:sale)
    @single_item_cost = @q.result.group('items.title').sum(:cost)
    @single_item_sale = @q.result.group('items.title').sum(:sale)
    @purchase_type_count = @q.result.group(:purchase_type).count
    @cost_by_date = @q.result.group('date(items.created_at)').sum(:cost)
    @sale_by_date = @q.result.group('date(items.created_at)').sum(:sale)
    @items_by_date = @q.result.group('date(items.created_at)').count
  
    respond_to do |format|
      format.js
    end
  end
  
  def get_item_data
    item = Item.find_by(id: params[:item_id])
    respond_to do |format|
      format.json { render json: {status: 'success',cost: item.cost,sale: item.sale,stock: item.stock}, status: :ok}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:item_type_id, :title, :code, :minimum, :optimal, :maximun, :comment, :status, :quantity_type, :weight_type, :stock,:cost,:sale, :measurement_quantity, :purchase_type)
    end

    def total_count_for_index
      @total_cost = @items.sum(:cost)
      @total_sale = @items.sum(:sale)
      @total_optimal = @items.sum(:optimal)
      @total_minimum = @items.sum(:minimum)
      @total_maximum = @items.sum(:maximun)
    end
end
