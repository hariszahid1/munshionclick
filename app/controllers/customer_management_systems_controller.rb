# frozen_string_literal: true

# CMS Controller
class CustomerManagementSystemsController < ApplicationController
	before_action :check_access
  before_action :index_search_data
  before_action :set_sys_user, only: %i[show edit update destroy]
  before_action :new_edit_data, only: %i[new edit create index]
  include PdfCsvGeneralMethod
  include CmsHelper

  require 'tempfile'
  require 'csv'
  # GET /customer_manangement_Systems
  # GET /customer_manangement_Systems.json
  def index
    @q = SysUser.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
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
      if @sys_user.save
        format.html { redirect_to get_request_referrer, notice: 'CMS user was successfully created.' }
        format.json { render :show, status: :created, location: @sys_user }
      else
        format.html { redirect_to get_request_referrer, alert: @sys_user.errors.full_messages[0] }
        format.json { render json: @sys_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer_manangement_Systems/1
  # PATCH/PUT /customer_manangement_Systems/1.json
  def update
    respond_to do |format|
      if @sys_user.update(sys_user_params)
        format.html { redirect_to get_request_referrer, notice: 'CMS user was successfully updated.' }
        format.json { render :show, status: :ok, location: @sys_user }
      else
        format.html { redirect_to get_request_referrer, alert: @sys_user.errors.full_messages[0] }
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

  def view_history
    @start_date = Date.today.beginning_of_month
    @end_date =  Date.today.end_of_month
    if params[:q].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      @item_id = params[:q][:item_id_eq] if params[:q][:item_id_eq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
    @event = %w[create update destroy]
    @q = PaperTrail::Version.where(item_type:"SysUser").order('created_at desc').ransack(params[:q])
    @cms_user_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end
  private

  def sys_user_params
    params.require(:sys_user).permit(
      :code,
      :cnic,
      :name,
      :user_type_id,
      :user_group,
      :status,
      :occupation,
      :credit_status,
      :credit_limit,
      :opening_balance,
      :profile_image,
      :balance,
      :gst,
      :ntn,
      :father,
      :nom_name,
      :nom_father,
      :nom_cnic,
      :nom_relation,
      :contact_attributes => [
        :id,
        :address,
        :home,
        :office,
        :mobile,
        :fax,
        :email,
        :comment,
        :status,
        :city_id,
        :country_id,
        :sys_user_id,
        :permanent_address
      ],
      :notes_attributes => [
        :id,
        :message,
        :assigned_to_id,
        :created_by,
        :notable_id,
        :notable_type
      ],
      :follow_ups_attributes =>[
        :id,
        :reminder_type,
        :task_type,
        :priority,
        :assigned_to_id,
        :created_by,
        :date,
        :comment,
        :followable_id,
        :followable_type
      ],
      cms_data: {}
      )
  end

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
    @project_name = @pos_setting.extra_settings.present? ? PosSetting.last.extra_settings['project_name']&.map(&:downcase) : []
    @client_type = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['client_type']&.map(&:downcase) : []
    @client_status = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['client_status'] : []
    @category = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['category']&.map(&:downcase) : []
    @deal_status = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['deal_status']&.map(&:downcase) : []
    @source = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['source']&.map(&:downcase) : []
  end

  def download_cms_csv_file
    @sys_user = @q.result
    header_for_csv = %w[Name Agent_name Project_Name Category Plot_size Short_Details Created_at]
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

  def index_search_data
    @options_for_select = SysUser.all
    created_by_ids = current_user.created_by_ids_list_to_view
		@all_agents = User.where('company_type=? or created_by_id=?',current_user.company_type,created_by_ids).pluck(:name, :id)
    @all_user = SysUser.all
    @all_plot_sizes = SysUser.pluck(:ntn).uniq
    @user_types = UserType.all
    @user_groups = UserGroup.all
    @follow_up_count = FollowUp.where(created_at: Time.current.all_day).count
  end
end
