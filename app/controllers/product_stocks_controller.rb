class ProductStocksController < ApplicationController
  before_action :set_product_stock, only: [:show, :edit, :update, :destroy]

  # GET /product_stocks
  # GET /product_stocks.json
  def index
    @products=Product.all
    @q = ProductStock.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'created_at desc' if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:product_title_cont]
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
    @product_stocks = @q.result(distinct: true).page(params[:page])
    @product_stock = @q.result(distinct: true)
    @in_stock=@product_stock.sum(:in_stock)
    @out_stock=@product_stock.sum(:out_stock)
    @stock=@product_stock.sum(:stock)
  end

  # GET /product_stocks/1
  # GET /product_stocks/1.json
  def show
  end

  # GET /product_stocks/new
  def new
    @products=Product.all
    @product_stock = ProductStock.new
  end

  # GET /product_stocks/1/edit
  def edit
    @products=Product.all
  end

  # POST /product_stocks
  # POST /product_stocks.json
  def create
    @product_stock = ProductStock.new(product_stock_params)

    respond_to do |format|
      if @product_stock.save
        format.html { redirect_to product_stocks_path, notice: 'Product stock was successfully created.' }
        format.json { render :show, status: :created, location: @product_stock }
      else
        @products=Product.all
        format.html { render :new }
        format.json { render json: @product_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_stocks/1
  # PATCH/PUT /product_stocks/1.json
  def update
    respond_to do |format|
      if @product_stock.update(product_stock_params)
        format.html { redirect_to product_stocks_path, notice: 'Product stock was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_stock }
      else
        @products=Product.all
        format.html { render :edit }
        format.json { render json: @product_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_stocks/1
  # DELETE /product_stocks/1.json
  def destroy
    @product_stock.destroy
    respond_to do |format|
      format.html { redirect_to product_stocks_url, notice: 'Product stock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_stock
      @product_stock = ProductStock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_stock_params
      params.require(:product_stock).permit(:product_id, :in_stock, :out_stock, :stock)
    end
end
