# frozen_string_literal: true

# MapColumns Controller
class MapColumnsController < ApplicationController
  require 'csv'
  before_action :set_map_column, only: %i[show edit update destroy]

  def index; end

  def show
    respond_to do |format|
      format.json { render json: @map_column }
    end
  end

  def new; end

  def edit; end

  def create
    @map_column = MapColumn.new(map_column_params)
    if map_column_params[:table_column].present? && map_column_params[:mapping_column].present? && @map_column.save
      flash[:notice] = "Column Mapping for #{@map_column.table_name} created successfully."
    else
      flash[:alert] = 'Column Mapping not created.'
    end
    redirect_to request.referrer
  end

  def update
    respond_to do |format|
      if @map_column.update(map_column_params)
        format.json { render json: "Column Mapping for #{@map_column.table_name} created successfully." }
      else
        format.json { render json: 'Please select column for mapping' }
      end
    end
  end

  def destroy
    @map_column.destroy
  end

  def generate_csv
    csv_of = generate_csv_params[:model_of].capitalize
    request.format = 'csv'
    respond_to do |format|
      format.html
      format.csv { send_data make_csv, filename: "#{csv_of}-#{Date.today}.csv" }
    end
    rescue StandardError => e
      flash[:alert] = "Error occurred, #{e.message}"
      redirect_back fallback_location: root_url
  end

  def make_csv
    @records = generate_csv_params[:model_of].classify.constantize.all
    mapping_ids = generate_csv_params[:mapping_ids]
    replaced_headers, values = Array.new(2) { [] }
    mapping_columns = MapColumn.where(id: mapping_ids).pluck(:table_column, :mapping_column).to_h
    headers = @records.last.attributes.keys
    extra_headers = headers.excluding(mapping_columns.keys)
    unless headers == extra_headers
      headers -= extra_headers
      headers.each { |h| replaced_headers.push mapping_columns[h] }
    end
    csv_headers = replaced_headers.present? ? replaced_headers : headers
    CSV.generate(headers: true) do |csv|
      csv << csv_headers

      @records.each do |record|
        headers.each { |h| values.push record.attributes[h] }
        csv.add_row values
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_map_column
    @map_column = MapColumn.find_by(id: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def map_column_params
    params.require(:map_column).permit(:table_column, :mapping_column, :table_name)
  end

  def generate_csv_params
    params.require(:generate_csv).permit!
  end
end
