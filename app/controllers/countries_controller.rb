class CountriesController < ApplicationController
  before_action :set_country, only: [:show, :edit, :update, :destroy]

  # GET /countries
  # GET /countries.json
  def index
    @q = Country.ransack(params[:q])
    return export_csv_and_pdf if params[:csv].present?
      @q.sorts = 'id asc' if @q.result.count > 0 && @q.sorts.empty?
    
    if params[:q].present?
      @title = params[:q][:title]
      @comment = params[:q][:comment]
    end
    @countries = @q.result(distinct: true).page(params[:page])

    if params[:submit_pdf_a4].present?
      @countries = @q.result
      print_pdf('Countries', 'pdf.html', 'A4')
    else
      @countries = @q.result.page(params[:page])
    end
  end




  def export_csv_and_pdf
    @countries = @q.result
    path = Rails.root.join('public/csv')
    @save_path = Rails.root.join(path, 'countries.csv')
    CSV.open(@save_path, 'wb') do |csv|
      headers = Country.column_names
      csv << headers
      @countries.each do |country|
        csv << country.as_json.values_at(*headers)
      end
    end
    @pos_setting = PosSetting.first
    subject = "#{@pos_setting.display_name} - Country Detail"
    email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : 'info@munshionclick.com'
    pdf = [[@countries, 'country']]
    body = ''
    ReportMailer.new_report_email(pdf, subject, email, '').deliver
    redirect_to countries_path
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
        format.html { render :new }
        format.json { render json: @country.errors, status: :unprocessable_entity }
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
        format.html { render :edit }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /countries/1
  # DELETE /countries/1.json
  def destroy
    @country.destroy
    respond_to do |format|
      format.html { redirect_to countries_url, notice: 'Country was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
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
end
