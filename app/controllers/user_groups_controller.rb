# frozen_string_literal: true

# UserGroup Controller
class UserGroupsController < ApplicationController
  include PdfCsvGeneralMethod
  include CitiesHelper
	before_action :check_access
  before_action :set_user_group, only: %i[show edit update destroy]
  require 'tempfile'
  require 'csv'
  # GET /user_groups
  # GET /user_groups.json
  def index
    @q = UserGroup.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = UserGroup.all
    @user_groups = @q.result.page(params[:page])
    download_user_groups_csv_file if params[:csv].present?
    download_user_groups_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
  end

  # GET /user_groups/1
  # GET /user_groups/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /user_groups/new
  def new
    @user_group = UserGroup.new
    respond_to do |format|
      format.js
    end
  end

  # GET /user_groups/1/edit
  def edit; end

  # POST /user_groups
  # POST /user_groups.json
  def create
    @user_group = UserGroup.new(user_group_params)

    respond_to do |format|
      if @user_group.save
        format.js
        format.html { redirect_to user_groups_path, notice: 'User Group was successfully created.' }
        format.json { render :show, status: :created, location: @user_group }
      else
        format.html { render :new }
        format.json { render json: @user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cities/1
  # PATCH/PUT /cities/1.json
  def update
    respond_to do |format|
      if @user_group.update(user_group_params)
        format.html { redirect_to user_groups_path, notice: 'User Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_group }
      else
        format.html { render :edit }
        format.json { render json: @user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_groups/1
  # DELETE /user_groups/1.json
  def destroy
    @user_group.destroy
    respond_to do |format|
      format.html { redirect_to user_groups_path, notice: 'User Group was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @user_group }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_group
    @user_group = UserGroup.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_group_params
    params.require(:user_group).permit(:title, :comment)
  end

  def download_user_groups_csv_file
    @user_groups = @q.result
    header_for_csv = %w[Id Title Comment]
    data_for_csv = get_data_for_user_groups_csv
    generate_csv(data_for_csv, header_for_csv, "User_groups-Total-#{@user_groups.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
  end

  def download_user_groups_pdf_file
    @user_groups = @q.result
    generate_pdf(@user_groups.as_json, "User_groups-Total-#{@user_groups.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}", 'pdf.html', 'A4')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'user_groups/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "User_groups-Total-#{@q.result.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
    if params[:email_value].present?
      flash[:notice] = "Email has been sent to #{params[:email_value]}"
    else
      flash[:notice] = "Email has been sent to #{current_user.email}"
    end
    redirect_to cities_path
  end

  def export_file
    export_data('UserGroup')
  end
end
