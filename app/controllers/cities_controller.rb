# frozen_string_literal: true

# Cities Controller
class CitiesController < ApplicationController
  include PdfCsvGeneralMethod
  include CitiesHelper

  before_action :set_city, only: %i[show edit update destroy]
  require 'tempfile'
  require 'csv'
  # GET /cities
  # GET /cities.json
  def index
    @q = City.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = City.all
    @cities = @q.result.page(params[:page])
    download_cities_csv_file if params[:csv].present?
    download_cities_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
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

  def download_cities_csv_file
    @cities = @q.result
    header_for_csv = %w[Id Title Comment]
    data_for_csv = get_data_for_cities_csv
    generate_csv(data_for_csv, header_for_csv, "Cities-Total-#{@cities.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
  end

  def download_cities_pdf_file
    @cities = @q.result
    generate_pdf(@cities.as_json, "Cities-Total-#{@cities.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}", 'pdf.html', 'A4', false)
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'cities/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "Cities-Total-#{@q.result.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
    if params[:email_value].present?
      flash[:notice] = "Email has been sent to #{params[:email_value]}"
    else
      flash[:notice] = "Email has been sent to #{current_user.email}"
    end
    redirect_to cities_path
  end

  def export_file
    export_data('City')
  end
end
