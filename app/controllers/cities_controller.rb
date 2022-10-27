# frozen_string_literal: true

# Cities Controller
class CitiesController < ApplicationController
  include PdfCsvEmailMethod

  before_action :set_city, only: %i[show edit update destroy]
  require 'tempfile'
  require 'csv'
  # GET /cities
  # GET /cities.json
  def index
    @q = City.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    if params[:q].present?
      @title = params[:q][:title]
      @comment = params[:q][:comment]
    end
    @cities = @q.result(distinct: true).page(params[:page])
    generate_csv(@q, 'cities') if params[:csv].present?
    generate_pdf(@q.result, 'Cities', 'pdf.html', 'A4') if params[:pdf].present?
    ids = @q.result.pluck(:id)
    EmailJob.perform_later(current_user, ids, 'City', 'cities', params[:email_value]) if params[:email].present?
    redirect_to cities_path if params[:email].present?
  end

  def export_csv_and_pdf
    @cities = @q.result
    path = Rails.root.join('public/csv')
    @save_path = Rails.root.join(path, 'cities.csv')
    CSV.open(@save_path, 'wb') do |csv|
      headers = City.column_names
      csv << headers
      @cities.each do |city|
        csv << city.as_json.values_at(*headers)
      end
    end
    @pos_setting = PosSetting.first
    subject = "#{@pos_setting.display_name} - City Detail"
    email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : 'info@munshionclick.com'
    pdf = [[@cities, 'city']]
    body = ''
    ReportMailer.new_report_email(pdf, subject, email, '').deliver
    redirect_to cities_path
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
        format.html { render :new }
        format.json { render json: @city.errors, status: :unprocessable_entity }
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
        format.html { render :edit }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cities/1
  # DELETE /cities/1.json
  def destroy
    @city.destroy
    respond_to do |format|
      format.html { redirect_to cities_url, notice: 'City was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render layout: false }
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
end
