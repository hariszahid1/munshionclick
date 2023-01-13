# frozen_string_literal: true

# pdf_templates Controller
class PdfTemplatesController < ApplicationController

  before_action :set_pdf_template, only: %i[show edit update destroy]

  # GET /pdf_templates
  # GET /pdf_templates.json
  def index
    @q = PdfTemplate.order('id desc').ransack(params[:q])
    @pdf_templates = @q.result.page(params[:page])
  end

  # GET /pdf_templates/1
  # GET /pdf_templates/1.json
  def show; end

  # GET /pdf_templates/new
  def new
    @pdf_template = PdfTemplate.new
  end

  # GET /pdf_templates/1/edit
  def edit; end

  # POST /pdf_templates
  # POST /pdf_templates.json
  def create
    @pdf_template = PdfTemplate.new(pdf_template_params)

    respond_to do |format|
      if @pdf_template.save
        format.js
        format.html { redirect_to pdf_templates_path, notice: 'PDF Template was successfully created.' }
        format.json { render :show, status: :created, location: @pdf_template }
      else
        format.html { redirect_to pdf_templates_path, alert: @pdf_template.errors.full_messages[0] }
      end
    end
  end

  # PATCH/PUT /pdf_templates/1
  # PATCH/PUT /pdf_templates/1.json
  def update
    respond_to do |format|
      if @pdf_template.update(pdf_template_params)
        format.html { redirect_to pdf_templates_path, notice: 'PDF Template was successfully updated.' }
        format.json { render :show, status: :ok, location: @pdf_template }
      else
        format.html { redirect_to pdf_templates_path, alert: @pdf_template.errors.full_messages[0] }
      end
    end
  end

  # DELETE /pdf_templates/1
  # DELETE /pdf_templates/1.json
  def destroy
    @pdf_template.destroy
    respond_to do |format|
      format.html { redirect_to pdf_templates_path, notice: 'PDF Template was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @pdf_template }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_pdf_template
    @pdf_template = PdfTemplate.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def pdf_template_params
    params.require(:pdf_template).permit(:title, :comment, :content, :table_name, :method_name, :logo)
  end

end
