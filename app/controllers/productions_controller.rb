class ProductionsController < ApplicationController
  before_action :set_production, only: [:show, :edit, :update, :destroy]

  # GET /productions
  # GET /productions.json
  def index
    @q = Production.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:title_eq]
    end
    @productions = @q.result(distinct: true).page(params[:page])
  end

  # GET /productions/1
  # GET /productions/1.json
  def show
    @items=Item.all
    @products=Product.all
  end

  # GET /productions/new
  def new
    @production = Production.new
    @items=Item.all
    @products=Product.all
  end

  # GET /productions/1/edit
  def edit
    @items=Item.all
    @products=Product.all
  end

  # POST /productions
  # POST /productions.json
  def create
    @production = Production.new(production_params)

    respond_to do |format|
      if @production.save!
        format.html { redirect_to productions_url, notice: 'Production was successfully created.' }
        format.json { render :show, status: :created, location: @production }
      else
        format.html { render :new }
        format.json { render json: @production.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /productions/1
  # PATCH/PUT /productions/1.json
  def update
    respond_to do |format|
      if @production.update(production_params)
        format.html { redirect_to productions_url, notice: 'Production was successfully updated.' }
        format.json { render :show, status: :ok, location: @production }
      else
        format.html { render :edit }
        format.json { render json: @production.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /productions/1
  # DELETE /productions/1.json
  def destroy
    @production.destroy
    respond_to do |format|
      format.html { redirect_to productions_url, notice: 'Production was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_production
      @production = Production.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def production_params
      params.require(:production).permit(:product_id, :operation_cost, :cost_price, :sale_price, :comment, :status,
      :materials_attributes => [:id,:production_id,:item_id,:product_id,:cost_price,:total_cost_price,:sale_price,:total_sale_price,:quantity,:comment,:status,:_destroy])
    end
end
