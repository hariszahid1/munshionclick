# frozen_string_literal: true

# Cities Controller
class CitiesController < ApplicationController
  include PdfCsvGeneralMethod
  include CitiesHelper

  before_action :check_access
  before_action :set_city, only: %i[show edit update destroy]
  require 'tempfile'
  require 'csv'
  # GET /cities
  # GET /cities.json
  def index
    @q = City.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = City.all
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @custom_pagination = @pos_setting.custom_pagination['cities'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['cities'].present?
    @cities = @q.result.page(params[:page]).per(@custom_pagination)

    if params[:csv].present?
      request.format = 'csv'
      download_cities_csv_file
    end
    download_cities_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    if params[:export_data].present?
      request.format = 'csv'
      export_file
    end

    @pdf_template = PdfTemplate.includes(:pdf_template_elements).find_by(table_name: 'city', method_name: 'index')
    @pdf_header = @pdf_template&.pdf_template_elements&.find_by(title: 'header')
    @pdf_footer = @pdf_template&.pdf_template_elements&.find_by(title: 'footer')
    @table_headers = @pdf_template&.pdf_template_elements&.find_by(title: 'table_headers')
    @table_data = @pdf_template&.pdf_template_elements&.find_by(title: 'table_data')
    dynamic_pdf if params[:dynamic_pdf].present?

    @total_cities_count = Contact.joins(:city).group('cities.title').count
    @city_title = @total_cities_count.keys.map { |a| a.gsub(' ', '-') }
    @city_user = @total_cities_count.values
    respond_to do |format|
      format.pdf
      format.csv
      format.js
      format.html
    end
  end

  # GET /cities/1
  # GET /cities/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /cities/new
  def new
    @city = City.new
    respond_to do |format|
      format.js
    end
  end

  # GET /cities/1/edit
  def edit; end

  # POST /cities
  # POST /cities.json
  def create
    @city = City.new(city_params)

    respond_to do |format|
      if @city.save
        format.js
        format.html { redirect_to cities_path, notice: 'City was successfully created.' }
        format.json { render :show, status: :created, location: @city }
      else
        format.html { redirect_to cities_path, alert: 'Title is already present!' }
      end
    end
  end

  # PATCH/PUT /cities/1
  # PATCH/PUT /cities/1.json
  def update
    respond_to do |format|
      if @city.update(city_params)
        format.html { redirect_to cities_path, notice: 'City was successfully updated.' }
        format.json { render :show, status: :ok, location: @city }
      else
        format.html { redirect_to cities_path, alert: 'Title is already present!' }
      end
    end
  end

  # DELETE /cities/1
  # DELETE /cities/1.json
  def destroy
    @city.destroy
    respond_to do |format|
      format.html { redirect_to cities_path, notice: 'City was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @city }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_city
    @city = City.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def city_params
    params.require(:city).permit(:title, :comment)
  end

  def dynamic_pdf
    @pos_setting = PosSetting.first
    request.format = 'pdf'
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'test-dynamic-pdf',
               template: 'cities/dynamic.pdf.erb',
               page_size: 'A4',
               orientation: 'Portrait',
               margin: {
                 margin_top: @pos_setting&.pdf_margin_top.to_f,
                 margin_right: @pos_setting&.pdf_margin_right.to_f,
                 margin_bottom: @pos_setting&.pdf_margin_bottom.to_f,
                 margin_left: @pos_setting&.pdf_margin_left.to_f
               },
               encoding: 'UTF-8',
               footer: {
                 right: '[page] of [topage]'
               },
               show_as_html: false
      end
    end
  end

  def download_cities_csv_file
    @cities = @q.result
    header_for_csv = %w[Id Title Comment]
    data_for_csv = get_data_for_cities_csv
    generate_csv(data_for_csv, header_for_csv,
                 "Cities-Total-#{@cities.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
  end

  def download_cities_pdf_file
    @cities = @q.result
    generate_pdf(@cities.as_json, "Cities-Total-#{@cities.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}",
                 'pdf.html', 'A4', false, 'cities/index.pdf.erb')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'cities/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "Cities-Total-#{@q.result.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
    flash[:notice] = if params[:email_value].present?
                       "Email has been sent to #{params[:email_value]}"
                     else
                       "Email has been sent to #{current_user.email}"
                     end
    redirect_to cities_path
  end

  def export_file
    export_data('City')
  end
end
