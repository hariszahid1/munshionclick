class UserTypesController < ApplicationController
	before_action :check_access
  before_action :set_user_type, only: [:show, :edit, :update, :destroy]
  include PdfCsvGeneralMethod
  include UserTypesHelper

  # GET /user_types
  # GET /user_types.json
  def index
    @q = UserType.ransack(params[:q])
    @options_for_select = UserType.all
    @user_types = @q.result.page(params[:page])
    download_user_types_csv_file if params[:csv].present?
    download_user_types_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
  end

  # GET /user_types/1
  # GET /user_types/1.json
  def show
     respond_to do |format|
      format.js
    end
  end

  # GET /user_types/new
  def new
    @user_type = UserType.new
    respond_to do |format|
      format.js
    end
  end

  # GET /user_types/1/edit
  def edit
  end

  # POST /user_types
  # POST /user_types.json
  def create
    @user_type = UserType.new(user_type_params)

    respond_to do |format|
      if @user_type.save
        format.js
        format.html { redirect_to user_types_path, notice: 'User type was successfully created.' }
        format.json { render :show, status: :created, location: @user_type }
      else
        format.html { redirect_to user_types_path, alert: 'Title is already present!' }
      end
    end
  end

  # PATCH/PUT /user_types/1
  # PATCH/PUT /user_types/1.json
  def update
    respond_to do |format|
      if @user_type.update(user_type_params)
        format.html { redirect_to user_types_path, notice: 'User type was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_type }
      else
        format.html { redirect_to user_types_path, alert: 'Title is already present!' }
      end
    end
  end

  # DELETE /user_types/1
  # DELETE /user_types/1.json
  def destroy
    @user_type.destroy
    respond_to do |format|
      format.html { redirect_to user_types_path, notice: 'User type was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @user_type }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user_type
    @user_type = UserType.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_type_params
    params.require(:user_type).permit(:title, :code, :discount_by_percentage, :discount_by_amount, :comment)
  end

  def download_user_types_csv_file
    @user_types = @q.result
    header_for_csv = %w[Id Title Code Discount_by_percentage Discount_by_amount Comment]
    data_for_csv = get_data_for_user_types_csv
    generate_csv(data_for_csv, header_for_csv, "user_types-Total-#{@user_types.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
  end

  def download_user_types_pdf_file
    sort_data_according
    @user_types = @q.result
    generate_pdf(@sorted_data.as_json, "user_types-Total-#{@sorted_data.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}", 'pdf.html', 'A4', false)
  end

  def send_email_file
    sort_data_according
    EmailJob.perform_later(@sorted_data.as_json, 'user_types/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "user_types-Total-#{@sorted_data.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
    if params[:email_value].present?
      flash[:notice] = "Email has been sent to #{params[:email_value]}"
    else
      flash[:notice] = "Email has been sent to #{current_user.email}"
    end
    redirect_to user_types_path
  end

  def sort_data_according
    @sorted_data = []
    @q.result.each do |d|
      @sorted_data << {
                        id: d.id,
                        title: d.title,
                        code: d.code,
                        Discount_by_percentage: d.discount_by_percentage,
                        Discount_by_amount: d.discount_by_amount,
                        comment: d.comment
                      }
    end
  end

  def export_file
    export_data('UserType')
  end

end
