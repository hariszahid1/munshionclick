# frozen_string_literal: true

# Cities Controller
class NotesController < ApplicationController
  # POST /notes
  # POST /notes.json
  def new
    @note = Note.new
    @staff = Staff.all
  end

  def create
    @note = Note.new(note_params)
    respond_to do |format|
      if @note.save
        format.js
        format.html { redirect_to crms_path(params[:note][:notable_id].to_i), notice: 'Note was successfully created.' }
        format.json { render :show, status: :created, location: @note }
      else
        format.html { render :new }
        format.json { render json: @note.errors, status: :unprocessable_entity }      \
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.

  # Never trust parameters from the scary internet, only allow the white list through.
  def note_params
    params.require(:note).permit(:message, :assigned_to_id, :created_by, :notable_type, :notable_id)
  end
end
