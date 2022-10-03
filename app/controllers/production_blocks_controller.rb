class ProductionBlocksController < ApplicationController
  before_action :set_production_block, only: [:show, :edit, :update, :destroy]

  # GET /production_blocks
  # GET /production_blocks.json
  def index
    @production_blocks = ProductionBlock.all
  end

  # GET /production_blocks/1
  # GET /production_blocks/1.json
  def show
  end

  # GET /production_blocks/new
  def new
    @production_block = ProductionBlock.new
  end

  # GET /production_blocks/1/edit
  def edit
  end

  # POST /production_blocks
  # POST /production_blocks.json
  def create
    @production_block = ProductionBlock.new(production_block_params)

    respond_to do |format|
      if @production_block.save
        format.html { redirect_to @production_block, notice: 'Production block was successfully created.' }
        format.json { render :show, status: :created, location: @production_block }
      else
        format.html { render :new }
        format.json { render json: @production_block.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /production_blocks/1
  # PATCH/PUT /production_blocks/1.json
  def update
    respond_to do |format|
      if @production_block.update(production_block_params)
        format.html { redirect_to @production_block, notice: 'Production block was successfully updated.' }
        format.json { render :show, status: :ok, location: @production_block }
      else
        format.html { render :edit }
        format.json { render json: @production_block.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /production_blocks/1
  # DELETE /production_blocks/1.json
  def destroy
    @production_block.destroy
    respond_to do |format|
      format.html { redirect_to production_blocks_url, notice: 'Production block was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_production_block
      @production_block = ProductionBlock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def production_block_params
      params.require(:production_block).permit(:production_block_type_id, :title, :bricks_quantity, :tile_quantity, :date, :status, :comment)
    end
end
