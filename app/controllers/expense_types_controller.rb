class ExpenseTypesController < ApplicationController
  include PdfCsvGeneralMethod
  include ExpenseTypesHelper
  before_action :check_access
  before_action :set_expense_type, only: %i[show edit update destroy]

  # GET /expense_types
  # GET /expense_types.json
  def index
    @q = ExpenseType.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = ExpenseType.all
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @custom_pagination = @pos_setting.custom_pagination['expense_types'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['expense_types'].present?
    @expense_types = @q.result.page(params[:page]).per(@custom_pagination)
    download_expense_types_csv_file if params[:csv].present?
    download_expense_types_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
  end

  # GET /expense_types/1
  # GET /expense_types/1.json
  def show; end

  # GET /expense_types/new
  def new
    @expense_type = ExpenseType.new
  end

  # GET /expense_types/1/edit
  def edit; end

  # POST /expense_types
  # POST /expense_types.json
  def create
    @expense_type = ExpenseType.new(expense_type_params)

    respond_to do |format|
      if @expense_type.save
        format.js
        format.html { redirect_to expense_types_path, notice: 'Expense type was successfully created.' }
        format.json { render :show, status: :created, location: @expense_type }
      else
        format.html { redirect_to expense_types_path, alert: 'Title is already present!' }
      end
    end
  end

  # PATCH/PUT /expense_types/1
  # PATCH/PUT /expense_types/1.json
  def update
    respond_to do |format|
      if @expense_type.update(expense_type_params)
        format.html { redirect_to expense_types_path, notice: 'Expense type was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense_type }
      else
        format.html { redirect_to expense_types_path, alert: 'Title is already present!' }
      end
    end
  end

  # DELETE /expense_types/1
  # DELETE /expense_types/1.json
  def destroy
    @expense_type.destroy
    respond_to do |format|
      format.html { redirect_to expense_types_path, notice: 'Expense Type was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @expense_type }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expense_type
    @expense_type = ExpenseType.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_type_params
    params.require(:expense_type).permit(:title, :comment)
  end

  def download_expense_types_csv_file
    @expense_type = @q.result
    header_for_csv = %w[Id Title Comment]
    data_for_csv = get_data_for_expense_types_csv
    generate_csv(data_for_csv, header_for_csv,
                 "ExpenseTypes-Total-#{@expense_type.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
  end

  def download_expense_types_pdf_file
    @expense_type = @q.result
    generate_pdf(@expense_type.as_json, "ExpenseTypes-Total-#{@expense_type.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}",
                 'pdf.html', 'A4', false, 'expense_types/index.pdf.erb')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'expense_types/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "ExpenseTypes-Total-#{@q.result.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
    flash[:notice] = if params[:email_value].present?
                       "Email has been sent to #{params[:email_value]}"
                     else
                       "Email has been sent to #{current_user.email}"
                     end
    redirect_to expense_types_path
  end

  def export_file
    export_data('ExpenseType')
  end
end
