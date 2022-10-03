class CompaignEntriesController < ApplicationController
  before_action :set_compaign_entry, only: %i[ show edit update destroy ]

  # GET /compaign_entries or /compaign_entries.json
  def index
    @compaign_entries = CompaignEntry.all
  end

  # GET /compaign_entries/1 or /compaign_entries/1.json
  def show
  end

  # GET /compaign_entries/new
  def new
    @compaign_entry = CompaignEntry.new
  end

  # GET /compaign_entries/1/edit
  def edit
  end

  # POST /compaign_entries or /compaign_entries.json
  def create
    @compaign_entry = CompaignEntry.new(compaign_entry_params)

    respond_to do |format|
      if @compaign_entry.save
        format.html { redirect_to compaign_entry_url(@compaign_entry), notice: "Compaign entry was successfully created." }
        format.json { render :show, status: :created, location: @compaign_entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @compaign_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /compaign_entries/1 or /compaign_entries/1.json
  def update
    respond_to do |format|
      if @compaign_entry.update(compaign_entry_params)
        format.html { redirect_to compaign_entry_url(@compaign_entry), notice: "Compaign entry was successfully updated." }
        format.json { render :show, status: :ok, location: @compaign_entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @compaign_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compaign_entries/1 or /compaign_entries/1.json
  def destroy
    @compaign_entry.destroy

    respond_to do |format|
      format.html { redirect_to compaign_entries_url, notice: "Compaign entry was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compaign_entry
      @compaign_entry = CompaignEntry.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def compaign_entry_params
      params.require(:compaign_entry).permit(:name)
    end
end
