class ItemTypesController < ApplicationController
  before_action :set_item_type, only: [:show, :edit, :update, :destroy, :get_item_type_products]

  # GET /item_types
  # GET /item_types.json
  def index
    @q = ItemType.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:title_eq]
      @code = params[:q][:code_eq]
    end
    @item_types = @q.result(distinct: true).page(params[:page])
    respond_to do |format|
      format.js {
        @item_types = @q.result(distinct: true)
        format.js
      }
      format.html
    end
  end

  # GET /item_types/1
  # GET /item_types/1.json
  def show
  end

  def get_item_type_products
    @products = @item_type.products
    respond_to do |format|
      format.js
    end
  end
  # GET /item_types/new
  def new
    @item_type = ItemType.new
  end

  # GET /item_types/1/edit
  def edit
  end

  # POST /item_types
  # POST /item_types.json
  def create
    @item_type = ItemType.new(item_type_params)

    respond_to do |format|
      if @item_type.save
        format.js
        format.html { redirect_to item_types_url, notice: 'Item type was successfully created.' }
        format.json { render :show, status: :created, location: @item_type }
      else
        format.html { render :new }
        format.json { render json: @item_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /item_types/1
  # PATCH/PUT /item_types/1.json
  def update
    respond_to do |format|
      if @item_type.update(item_type_params)
        format.html { redirect_to item_types_url, notice: 'Item type was successfully updated.' }
        format.json { render :show, status: :ok, location: @item_type }
      else
        format.html { render :edit }
        format.json { render json: @item_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /item_types/1
  # DELETE /item_types/1.json
  def destroy
    @item_type.destroy
    respond_to do |format|
      format.html { redirect_to item_types_url, notice: 'Item type was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_type
      @item_type = ItemType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_type_params
      params.require(:item_type).permit(:title, :code, :comment)
    end
end
