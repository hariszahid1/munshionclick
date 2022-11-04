class DepartmentsController < ApplicationController
  include PdfCsvGeneralMethod
  include DepartmentsHelper
	before_action :check_access
  before_action :set_department, only: [:show, :edit, :update, :destroy]
  # GET /departments
  # GET /departments.json
  def index
    @q = Department.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = Department.all
    @departments = @q.result(distinct: true).page(params[:page])
    download_departments_csv_file if params[:csv].present?
    download_departments_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
  end

  # GET /departments/1
  # GET /departments/1.json
  def show
        respond_to do |format|
      format.js
    end
  end

  # GET /departments/new
  def new
    @department = Department.new
        respond_to do |format|
      format.js
    end
  end

  # GET /departments/1/edit
  def edit
        respond_to do |format|
      format.js
    end
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = Department.new(department_params)

    respond_to do |format|
      if @department.save
        format.js
        format.html { redirect_to departments_path, notice: 'Department was successfully created.' }
        format.json { render :show, status: :created, location: @department }
      else
        format.html { redirect_to departments_path, alert: 'Title is already present!' }
      end
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to departments_path, notice: 'Department was successfully updated.' }
        
      else
        format.html { redirect_to departments_path, alert: 'Title is already present!' }
      end
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    @department.destroy
    respond_to do |format|
      format.html { redirect_to departments_path, notice: 'Department was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @department }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_department
    @department = Department.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def department_params
    params.require(:department).permit(:code, :title, :comment, :status)
  end
  def download_departments_csv_file
    @departments = @q.result
    header_for_csv = %w[Id Title Comment Code]
    data_for_csv = get_data_for_departments_csv
    generate_csv(data_for_csv, header_for_csv, "Departments-Total-#{@departments.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
  end

  def download_departments_pdf_file
    @departments = @q.result
    generate_pdf(@departments.as_json, "Departments-Total-#{@departments.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}", 'pdf.html', 'A4')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'departments/index.pdf.erb', params[:email_value],
                            params[:email_choice], params[:subject], params[:body],
                            current_user, 'departments')
    if params[:email_value].present?
      flash[:notice] = "Email has been sent to #{params[:email_value]}"
    else
      flash[:notice] = "Email has been sent to #{current_user.email}"
    end
    redirect_to departments_path
  end

  def export_file
    export_data('Department')
  end
end
