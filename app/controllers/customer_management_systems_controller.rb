# frozen_string_literal: true

# CMS Controller
class CustomerManagementSystemsController < ApplicationController
	before_action :check_access
  before_action :set_sys_user, only: %i[show edit update destroy]
  before_action :new_edit_data, only: %i[new edit index]
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
    download_cms_csv_file if params[:csv].present?
    download_cms_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
  end

  def new
    @sys_user = SysUser.new
    @raw_products = RawProduct.all
    @sys_user.build_contact
    @sys_user.notes.build
    @sys_user.follow_ups.build
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

  def destroy
    @sys_user.destroy!
    respond_to do |format|
      format.html { redirect_to customer_management_systems_path, notice: 'CMS user was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @sys_user }
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
    @staff = Staff.all
    @pos_setting = PosSetting.last
    @project_name = @pos_setting.extra_settings.present? ? PosSetting.last.extra_settings['project_name'] : []
    @client_type = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['client_type'] : []
    @client_status = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['client_status'] : []
    @category = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['category'] : []
    @deal_status = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['deal_status'] : []
    @source = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['source'] : []
  end

  def download_cms_csv_file
    @sys_user = @q.result
    header_for_csv = %w[Number Name Project_Name Client_Type Client_status Category Deal_Status
                        Source Plot_size Short_Details Created_at City Country
                        ]
    data_for_csv = get_data_for_cms_csv
    generate_csv(data_for_csv, header_for_csv, 'CMS')
  end

  def download_cms_pdf_file
    @sys_users = @q.result
    sorted_data
    generate_pdf(@sorted_data.as_json, 'CMS', 'pdf.html', 'A4', false, 'customer_management_systems/index.pdf.erb')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'customer_management_systems/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, 'customer_management_systems')
    if params[:email_value].present?
      flash[:notice] = "Email has been sent to #{params[:email_value]}"
    else
      flash[:notice] = "Email has been sent to #{current_user.email}"
    end
    redirect_to customer_management_systems_path
  end

  def export_file
    export_data('SysUser')
  end
end
