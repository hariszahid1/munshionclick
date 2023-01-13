class StickyNotesController < ApplicationController
  def index
    @sticky_notes = StickyNote.all
  end

  def create
    @sticky_note = StickyNote.new(title: 'Title', content: 'content', x_pos: 0, y_pos: 0, color_code: '#feff9c')
    if @sticky_note.save!
      respond_to do |format|
        format.json { render json: { status: :success, data: @sticky_note } }
      end
    else
      format.json { render json: { status: :error, error: @sticky_note.errors.full_messages } }
    end
  end

  def update
    @sticky_note = StickyNote.find(params[:id])
    @sticky_note.update(sticky_note_params)
  end

  def destroy
    @sticky_note = StickyNote.find(params[:id])
    @sticky_note.destroy
  end

  private

  def sticky_note_params
    params.permit(:title, :content, :x_pos, :y_pos, :color_code)
  end
end
