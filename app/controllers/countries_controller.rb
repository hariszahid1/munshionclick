class CountriesController < ApplicationController
  before_action :set_country, only: [:show, :edit, :update, :destroy]
  include PdfCsvGeneralMethod
  include CountriesHelper

  # GET /countries
  # GET /countries.json
  def index
    @q = Country.ransack(params[:q])
    @q.sorts = 'id asc' if @q.result.count > 0 && @q.sorts.empty?
    @options_for_select = Country.all
    @countries = @q.result(distinct: true).page(params[:page])
    download_countries_csv_file if params[:csv].present?
    download_countries_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
  end

  # GET /countries/1
  # GET /countries/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /countries/new
  def new
    @country = Country.new
    respond_to do |format|
      format.js
    end

  end

  # GET /countries/1/edit
  def edit
        respond_to do |format|
      format.js
    end

  end

  # POST /countries
  # POST /countries.json
  def create
    @country = Country.new(country_params)

    respond_to do |format|
      if @country.save
        format.js
        format.html { redirect_to countries_path, notice: 'Country was successfully created.' }
        format.json { render :show, status: :created, location: @country }
      else
        format.html { redirect_to countries_path, alert: 'Title is already present!' }
      end
    end
  end

  # PATCH/PUT /countries/1
  # PATCH/PUT /countries/1.json
  def update
    respond_to do |format|
      if @country.update(country_params)
        format.html { redirect_to countries_path, notice: 'Country was successfully updated.' }
        format.json { render :show, status: :ok, location: @country }
      else
        format.html { redirect_to countries_path, alert: 'Title is already present!' }
      end
    end
  end

  # DELETE /countries/1
  # DELETE /countries/1.json
  def destroy
    @country.destroy
    respond_to do |format|
      format.html { redirect_to countries_path, notice: 'Country was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @country }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_country
    @country = Country.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def country_params
    params.require(:country).permit(:title, :comment)
  end

  def download_countries_csv_file
    @countries = @q.result
    header_for_csv = %w[Id Title Comment]
    data_for_csv = get_data_for_countries_csv
    generate_csv(data_for_csv, header_for_csv, 'countries')
  end

  def download_countries_pdf_file
    @countries = @q.result
    generate_pdf(@countries.as_json, 'Countries', 'pdf.html', 'A4')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'countries/index.pdf.erb', params[:email_value],
                            params[:email_choice], params[:subject], params[:body],
                            current_user, 'countries')
    if params[:email_value].present?
      flash[:notice] = "Email has been sent to #{params[:email_value]}"
    else
      flash[:notice] = "Email has been sent to #{current_user.email}"
    end
    redirect_to countries_path
  end

  def export_file
    export_data('Country')
  end
end
