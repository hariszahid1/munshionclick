# frozen_string_literal: true

# CMS Controller
class CustomerManagementSystemsController < ApplicationController
  before_action :set_sys_user, only: %i[show edit update destroy]
  before_action :new_edit_data, only: %i[new edit]
  include PdfCsvGeneralMethod
  include CmsHelper

  require 'tempfile'
  require 'csv'
  # GET /customer_manangement_Systems
  # GET /customer_manangement_Systems.json
  def index
    @q = SysUser.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = SysUser.all
    @all_user = SysUser.all
    @user_types = UserType.all
    @user_groups = UserGroup.all
    @sys_users = @q.result.page(params[:page])
    export_file if params[:export_data].present?
    download_cities_csv_file if params[:csv].present?
    download_cities_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
  end

  def new
    @sys_user = SysUser.new
    @raw_products = RawProduct.all
    @sys_user.build_contact
    respond_to do |format|
      format.js
    end
  end

  def edit; end

  def show; end

  # POST /customer_manangement_Systems
  # POST /customer_manangement_Systems.json
  def create
    @sys_user = SysUser.new(sys_user_params)

    respond_to do |format|
      if @sys_user.save!
        format.html { redirect_to get_request_referrer, notice: 'Sys user was successfully created.' }
        format.json { render :show, status: :created, location: @sys_user }
      else
        format.html { render :new }
        format.json { render json: @sys_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer_manangement_Systems/1
  # PATCH/PUT /customer_manangement_Systems/1.json
  def update
    respond_to do |format|
      if @sys_user.update!(sys_user_params)
        format.html { redirect_to get_request_referrer, notice: 'Sys user was successfully updated.' }
        format.json { render :show, status: :ok, location: @sys_user }
      else
        format.html { render :edit }
        format.json { render json: @sys_user.errors, status: :unprocessable_entity }
      end
    end
  end
  private

  def set_sys_user
    @sys_user = SysUser.find(params[:id])
  end

  def new_edit_data
    @user_types = UserType.all
    @cities = City.all
    @countries = Country.all
    @user_groups = UserGroup.all
  end

  def download_cities_csv_file
    @sys_user = @q.result.as_json
    header1 = SysUser.column_names.excluding('id', 'created_at', 'updated_at')
    header2 = Contact.column_names.excluding('id', 'created_at', 'updated_at', 'sys_user_id')
    header_for_csv = header1 + header2
    data_for_csv = get_data_for_cms_csv
    generate_csv(data_for_csv, header_for_csv, 'sys_user')
  end

  def download_cities_pdf_file
    @sys_users = @q.result
    generate_pdf(@sys_users.as_json, 'SysUsers', 'pdf.html', 'A4')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'cities/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, 'cities')
    if params[:email_value].present?
      flash[:notice] = "Email has been sent to #{params[:email_value]}"
    else
      flash[:notice] = "Email has been sent to #{current_user.email}"
    end
    redirect_to cities_path
  end

  def export_file
    export_data('SysUser')
  end
end
