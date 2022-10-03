class PurchaseSaleItemsController < ApplicationController
  before_action :set_purchase_sale_item, only: [:show, :edit, :update, :destroy]

  # GET /purchase_sale_items
  # GET /purchase_sale_items.json
  def index
    @purchase_sale_items = PurchaseSaleItem.all
  end

  # GET /purchase_sale_items/1
  # GET /purchase_sale_items/1.json
  def show
  end

  # GET /purchase_sale_items/new
  def new
    @purchase_sale_item = PurchaseSaleItem.new
  end

  # GET /purchase_sale_items/1/edit
  def edit
  end

  # POST /purchase_sale_items
  # POST /purchase_sale_items.json
  def create
    @purchase_sale_item = PurchaseSaleItem.new(purchase_sale_item_params)
    respond_to do |format|
      if @purchase_sale_item.save
        format.html { redirect_to purchase_sale_items_url, notice: 'Purchase sale item was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_sale_item }
      else
        format.html { render :new }
        format.json { render json: @purchase_sale_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_sale_items/1
  # PATCH/PUT /purchase_sale_items/1.json
  def update
    respond_to do |format|
      if @purchase_sale_item.update(purchase_sale_item_params)
        format.html { redirect_to purchase_sale_items_url, notice: 'Purchase sale item was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_sale_item }
      else
        format.html { render :edit }
        format.json { render json: @purchase_sale_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_sale_items/1
  # DELETE /purchase_sale_items/1.json
  def destroy
    @purchase_sale_item.destroy
    respond_to do |format|
      format.html { redirect_to purchase_sale_items_url, notice: 'Purchase sale item was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_sale_item
      @purchase_sale_item = PurchaseSaleItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_sale_item_params
      params.require(:purchase_sale_item).permit(:purchase_sale_detail_id,:expiry, :item_id, :product_id,:quantity, :cost_price, :sale_price, :status, :comment,:transaction_type,:size_1,:size_2,:size_3,:size_4,:size_5,:size_6,:size_7,:size_8,:size_9,:size_10,:size_11,:size_12,:size_13)
    end
end
