class RawProductsController < ApplicationController
  before_action :set_raw_product, only: [:show, :edit, :update, :destroy]

  # GET /raw_products
  # GET /raw_products.json
  def index
    @q = RawProduct.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:title_or_code_cont]
      @code = params[:q][:code_eq]
    end
    @raw_products = @q.result(distinct: true).page(params[:page])
  end

  # GET /raw_products/1
  # GET /raw_products/1.json
  def show
  end

  # GET /raw_products/new
  def new
    @raw_product = RawProduct.new
  end

  # GET /raw_products/1/edit
  def edit
  end

  # POST /raw_products
  # POST /raw_products.json
  def create
    @raw_product = RawProduct.new(raw_product_params)

    respond_to do |format|
      if @raw_product.save
        format.html { redirect_to raw_products_url, notice: 'Raw product was successfully created.' }
        format.json { render :show, status: :created, location: @raw_product }
      else
        format.html { render :new }
        format.json { render json: @raw_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /raw_products/1
  # PATCH/PUT /raw_products/1.json
  def update
    respond_to do |format|
      if @raw_product.update(raw_product_params)
        format.html { redirect_to raw_products_url, notice: 'Raw product was successfully updated.' }
        format.json { render :show, status: :ok, location: @raw_product }
      else
        format.html { render :edit }
        format.json { render json: @raw_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /raw_products/1
  # DELETE /raw_products/1.json
  def destroy
    @raw_product.destroy
    respond_to do |format|
      format.html { redirect_to raw_products_url, notice: 'Raw product was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_raw_product
      @raw_product = RawProduct.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def raw_product_params
      params.require(:raw_product).permit(:code, :title, :stock, :acquire_type, :cost, :sale, :minimum, :optimal, :maximum, :first_stock, :second_stock, :third_stock, :nakasi_stock)
    end
end
