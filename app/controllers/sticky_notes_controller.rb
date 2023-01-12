class StickyNotesController < ApplicationController
  def index
    @sticky_notes = StickyNote.all
  end

  def create
    @sticky_note = StickyNote.new(sticky_note_params)
    if @sticky_note.save
      render json: @sticky_note
    else
      render json: @sticky_note.errors, status: :unprocessable_entity
    end
  end

  def update
    byebug
  end

  private

  def sticky_note_params
    params.require(:sticky_note).permit(:title, :content, :x_pos, :y_pos)
  end
end
