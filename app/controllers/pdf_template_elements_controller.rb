# frozen_string_literal: true

# pdf_template_elements Controller
class PdfTemplateElementsController < ApplicationController

  before_action :set_pdf_template_element, only: %i[show edit update destroy]

  # GET /pdf_template_elements
  # GET /pdf_template_elements.json
  def index
    @q = PdfTemplateElement.order('id desc').ransack(params[:q])
    @pdf_template_elements = @q.result.page(params[:page])
  end

  # GET /pdf_template_elements/1
  # GET /pdf_template_elements/1.json
  def show; end

  # GET /pdf_template_elements/new
  def new
    @pdf_template_element = PdfTemplateElement.new
  end

  # GET /pdf_template_elements/1/edit
  def edit; end

  # POST /pdf_template_elements
  # POST /pdf_template_elements.json
  def create
    @pdf_template_element = PdfTemplateElement.new(pdf_template_element_params)

    respond_to do |format|
      if @pdf_template_element.save
        format.js
        format.html { redirect_to pdf_template_elements_path, notice: 'City was successfully created.' }
        format.json { render :show, status: :created, location: @pdf_template_element }
      else
        format.html { redirect_to pdf_template_elements_path, alert: @pdf_template_element.errors.full_messages[0] }
      end
    end
  end

  # PATCH/PUT /pdf_template_elements/1
  # PATCH/PUT /pdf_template_elements/1.json
  def update
    respond_to do |format|
      if @pdf_template_element.update(pdf_template_element_params)
        format.html { redirect_to pdf_template_elements_path, notice: 'Pdf template element was successfully updated.' }
        format.json { render :show, status: :ok, location: @pdf_template_element }
      else
        format.html { redirect_to pdf_template_elements_path, alert: @pdf_template_element.errors.full_messages[0] }
      end
    end
  end

  # DELETE /pdf_template_elements/1
  # DELETE /pdf_template_elements/1.json
  def destroy
    @pdf_template_element.destroy
    respond_to do |format|
      format.html { redirect_to pdf_template_elements_path, notice: 'Pdf template element was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @pdf_template_element }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_pdf_template_element
    @pdf_template_element = PdfTemplateElement.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def pdf_template_element_params
    params.require(:pdf_template_element).permit(:title, :comment, :pdf_template_id, :content)
  end

end
