class ProductionBlockTypesController < ApplicationController
	before_action :check_access
  before_action :set_production_block_type, only: [:show, :edit, :update, :destroy]

  # GET /production_block_types
  # GET /production_block_types.json
  def index
    @q = ProductionBlockType.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:title_eq]
    end
    @production_block_types = @q.result(distinct: true).page(params[:page])
  end

  # GET /production_block_types/1
  # GET /production_block_types/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /production_block_types/new
  def new
    @production_block_type = ProductionBlockType.new
        respond_to do |format|
      format.js
    end
  end

  # GET /production_block_types/1/edit
  def edit
        respond_to do |format|
      format.js
    end
  end

  # POST /production_block_types
  # POST /production_block_types.json
  def create
    @production_block_type = ProductionBlockType.new(production_block_type_params)

    respond_to do |format|
      if @production_block_type.save
        format.js
        format.html { redirect_to production_block_types_url, notice: 'Production block type was successfully created.' }
        format.json { render :show, status: :created, location: @production_block_type }
      else
        format.html { render :new }
        format.json { render json: @production_block_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /production_block_types/1
  # PATCH/PUT /production_block_types/1.json
  def update
    respond_to do |format|
      if @production_block_type.update(production_block_type_params)
        format.html { redirect_to production_block_types_url, notice: 'Production block type was successfully updated.' }
        format.json { render :show, status: :ok, location: @production_block_type }
      else
        format.html { render :edit }
        format.json { render json: @production_block_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /production_block_types/1
  # DELETE /production_block_types/1.json
  def destroy
    @production_block_type.destroy
    respond_to do |format|
      format.html { redirect_to production_block_types_url, notice: 'Production Block Type was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @production_block_type }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_production_block_type
      @production_block_type = ProductionBlockType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def production_block_type_params
      params.require(:production_block_type).permit(:title, :quantity, :status, :comment)
    end
end
