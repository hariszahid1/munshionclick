class ExpenseTypesController < ApplicationController
  include PdfCsvGeneralMethod
  include ExpenseTypesHelper
  before_action :set_expense_type, only: [:show, :edit, :update, :destroy]

  # GET /expense_types
  # GET /expense_types.json
  def index
    @q = ExpenseType.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = ExpenseType.all
    @expense_types = @q.result(distinct: true).page(params[:page]).per(50)
    download_expense_types_csv_file if params[:csv].present?
    download_expense_types_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
  end

  # GET /expense_types/1
  # GET /expense_types/1.json
  def show
  end

  # GET /expense_types/new
  def new
    @expense_type = ExpenseType.new
  end

  # GET /expense_types/1/edit
  def edit
  end

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
        format.html { render :new }
        format.json { render json: @expense_type.errors, status: :unprocessable_entity }
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
        format.html { render :edit }
        format.json { render json: @expense_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expense_types/1
  # DELETE /expense_types/1.json
  def destroy
    @expense_type.destroy
    respond_to do |format|
      format.html { redirect_to expense_types_url, notice: 'Expense type was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
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
      data_for_csv = get_data_for_expense_type_csv
      generate_csv(data_for_csv, header_for_csv, 'expense_type')
    end
  
    def download_expense_types_pdf_file
      @expense_type = @q.result
      generate_pdf(@expense_type.as_json, 'Expense_type', 'pdf.html', 'A4')
    end
  
    def send_email_file
      EmailJob.perform_later(@q.result.as_json, 'expense_types/index.pdf.erb', params[:email_value],
                             params[:email_choice], params[:subject], params[:body],
                             current_user, 'expense_types')
      if params[:email_value].present?
        flash[:notice] = "Email has been sent to #{params[:email_value]}"
      else
        flash[:notice] = "Email has been sent to #{current_user.email}"
      end
      redirect_to expense_types_path
    end
  
    def export_file
      export_data('ExpenseType')
    end
end
