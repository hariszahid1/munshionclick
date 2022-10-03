class StaffRawProductsController < ApplicationController
  before_action :set_staff_raw_product, only: [:show, :edit, :update, :destroy]

  # GET /staff_raw_products
  # GET /staff_raw_products.json
  def index
    @staff_raw_products = StaffRawProduct.all
  end

  # GET /staff_raw_products/1
  # GET /staff_raw_products/1.json
  def show
  end

  # GET /staff_raw_products/new
  def new
    @staff_raw_product = StaffRawProduct.new
  end

  # GET /staff_raw_products/1/edit
  def edit
  end

  # POST /staff_raw_products
  # POST /staff_raw_products.json
  def create
    @staff_raw_product = StaffRawProduct.new(staff_raw_product_params)

    respond_to do |format|
      if @staff_raw_product.save
        format.html { redirect_to @staff_raw_product, notice: 'Staff raw product was successfully created.' }
        format.json { render :show, status: :created, location: @staff_raw_product }
      else
        format.html { render :new }
        format.json { render json: @staff_raw_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /staff_raw_products/1
  # PATCH/PUT /staff_raw_products/1.json
  def update
    respond_to do |format|
      if @staff_raw_product.update(staff_raw_product_params)
        format.html { redirect_to @staff_raw_product, notice: 'Staff raw product was successfully updated.' }
        format.json { render :show, status: :ok, location: @staff_raw_product }
      else
        format.html { render :edit }
        format.json { render json: @staff_raw_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_raw_products/1
  # DELETE /staff_raw_products/1.json
  def destroy
    @staff_raw_product.destroy
    respond_to do |format|
      format.html { redirect_to staff_raw_products_url, notice: 'Staff raw product was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_staff_raw_product
      @staff_raw_product = StaffRawProduct.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def staff_raw_product_params
      params.require(:staff_raw_product).permit(:staff_id, :raw_product_id)
    end
end
