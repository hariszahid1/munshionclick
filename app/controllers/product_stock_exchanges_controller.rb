class ProductStockExchangesController < ApplicationController
  before_action :set_product_stock_exchange, only: [:show, :edit, :update, :destroy]

  # GET /product_stock_exchanges
  # GET /product_stock_exchanges.json
  def index
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
    @q = ProductStockExchange.ransack(params[:q])

    @products = Product.all
    @product_stock_exchanges = @q.result
    @total_quantity=@product_stock_exchanges.pluck('SUM(quantity)')

    if params[:submit_pdf].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @ledger_books_pdf=@q.result
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
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

  # GET /product_stock_exchanges/1
  # GET /product_stock_exchanges/1.json
  def show
  end

  # GET /product_stock_exchanges/new
  def new
    @products = Product.all
    @product_stock_exchange = ProductStockExchange.new
  end

  # GET /product_stock_exchanges/1/edit
  def edit
    @products = Product.all
  end

  # POST /product_stock_exchanges
  # POST /product_stock_exchanges.json
  def create
    @product_stock_exchange = ProductStockExchange.new(product_stock_exchange_params)

    respond_to do |format|
      if @product_stock_exchange.save
        stock = @product_stock_exchange.product.stock
        rec_stock = @product_stock_exchange.product_recipient.stock
        @product_stock_exchange.product.update(stock: stock-@product_stock_exchange.quantity)
        @product_stock_exchange.product_recipient.update(stock: rec_stock+@product_stock_exchange.quantity)
        format.html { redirect_to product_stock_exchanges_path, notice: 'Product stock exchange was successfully created.' }
        format.json { render :show, status: :created, location: @product_stock_exchange }
      else
        @products = Product.all
        format.html { render :new }
        format.json { render json: @product_stock_exchange.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_stock_exchanges/1
  # PATCH/PUT /product_stock_exchanges/1.json
  def update
    respond_to do |format|
      stock = @product_stock_exchange.product.stock
      rec_stock = @product_stock_exchange.product_recipient.stock
      quantity = @product_stock_exchange.quantity
      if @product_stock_exchange.update(product_stock_exchange_params)
        @product_stock_exchange.product.update(stock: stock+(quantity-@product_stock_exchange.quantity))
        @product_stock_exchange.product_recipient.update(stock: rec_stock-(quantity-@product_stock_exchange.quantity))
        format.html { redirect_to @product_stock_exchange, notice: 'Product stock exchange was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_stock_exchange }
      else
        @products = Product.all
        format.html { render :edit }
        format.json { render json: @product_stock_exchange.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_stock_exchanges/1
  # DELETE /product_stock_exchanges/1.json
  def destroy
    stock = @product_stock_exchange.product.stock
    rec_stock = @product_stock_exchange.product_recipient.stock
    @product_stock_exchange.product.update(stock: stock+@product_stock_exchange.quantity)
    @product_stock_exchange.product_recipient.update(stock: rec_stock-@product_stock_exchange.quantity)
    @product_stock_exchange.destroy
    respond_to do |format|
      format.html { redirect_to product_stock_exchanges_url, notice: 'General Setting was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }

    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_stock_exchange
      @product_stock_exchange = ProductStockExchange.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_stock_exchange_params
      params.require(:product_stock_exchange).permit(:product_id, :product_recipient_id,:created_at, :quantity)
    end
end
