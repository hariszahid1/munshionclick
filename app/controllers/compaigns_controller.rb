class CompaignsController < ApplicationController
  before_action :set_compaign, only: %i[ show edit update destroy ]
  before_action :check_access

  # GET /compaigns or /compaigns.json
  def index
    @start_date = DateTime.current.beginning_of_month
    @end_date = DateTime.now
    if params[:q].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @q = Compaign.includes(:compaign_entries).ransack(params[:q])
    else
      @q = Compaign.includes(:compaign_entries).where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).ransack(params[:q])
    end
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    if params[:submit_pdf_a4].present?
      @compaigns = @q.result
      print_pdf('Compaign From -'+@start_date.to_s+' to '+@end_date.to_s,'pdf.html','A4')
    else
      @compaigns = @q.result.page(params[:page])
    end

  end


  # GET /compaigns/1 or /compaigns/1.json
  def show
  end

  # GET /compaigns/new
  def new
    @compaign = Compaign.new
    @compaign.compaign_entries.build

  end

  # GET /compaigns/1/edit
  def edit
  end

  # POST /compaigns or /compaigns.json
  def create
    @compaign = Compaign.new(compaign_params)

    respond_to do |format|
      if @compaign.save
        format.html { redirect_to compaigns_path, notice: "Compaign was successfully created." }
        format.json { render :show, status: :created, location: @compaign }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @compaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /compaigns/1 or /compaigns/1.json
  def update
    respond_to do |format|
      if @compaign.update(compaign_params)
        format.html { redirect_to compaigns_path, notice: "Compaign was successfully updated." }
        format.json { render :show, status: :ok, location: @compaign }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @compaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compaigns/1 or /compaigns/1.json
  def destroy
    @compaign.destroy

    respond_to do |format|
      format.html { redirect_to compaigns_path, notice: "Compaign was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compaign
      @compaign = Compaign.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def compaign_params
      params.require(:compaign).permit(:title, :comment,
      :compaign_entries_attributes => [:id, :compaign_id, :name, :phone,:mobile, :email, :comment,:_destroy])
    end
end
