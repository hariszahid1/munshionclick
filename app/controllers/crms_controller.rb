# frozen_string_literal: true

# CRM Controller
class CrmsController < ApplicationController
  before_action :check_access
  before_action :index_search_data
  before_action :set_sys_user, only: %i[show edit update destroy]
  before_action :new_edit_data, only: %i[new edit create index]
  include PdfCsvGeneralMethod
  include CrmHelper

  require 'tempfile'
  require 'csv'
  # GET /crms
  # GET /crms.json
  def index
    if current_user&.extra_settings.try(:[], 'show_all_crm_users').present?
      @q = SysUser.order('id desc').where(for_crms: [true, false]).ransack(params[:q])
    else
      @q = SysUser.order('id desc').where(for_crms: [true, false], credit_status: current_user&.id).ransack(params[:q])
    end
    @options_for_select = SysUser.all
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @custom_pagination = @pos_setting.custom_pagination['sys_users'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['sys_users'].present?
    @sys_users = @q.result.page(params[:page]).per(@custom_pagination)
    export_file if params[:export_data].present?
    download_crm_csv_file if params[:csv].present?
    download_crm_pdf_file if params[:pdf].present?
    download_associated_pdf if params[:pdf_associated_data].present?
    send_email_file if params[:email].present?
    crm_charts
  end

  def new
    @sys_user = SysUser.new
    @raw_products = RawProduct.all
    @sys_user.build_contact
    @sys_user.notes.build
    @sys_user.follow_ups.build
  end

  def edit; end

  def show; end

  # POST /crms
  # POST /crms.json
  def create
    @sys_user = SysUser.new(sys_user_params)

    respond_to do |format|
      if @sys_user.save
        format.html { redirect_to get_request_referrer, notice: 'CRM user was successfully created.' }
        format.json { render :show, status: :created, location: @sys_user }
      else
        format.html { redirect_to get_request_referrer, alert: @sys_user.errors.full_messages[0] }
        format.json { render json: @sys_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /crms/1
  # PATCH/PUT /crms/1.json
  def update
    respond_to do |format|
      if @sys_user.update(sys_user_params)
        format.html { redirect_to get_request_referrer, notice: 'CRM user was successfully updated.' }
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
      format.html { redirect_to crms_path, notice: 'CRM user was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @sys_user }
    end
  end

  def view_history
    @start_date = Date.today.beginning_of_month
    @end_date = Date.today.end_of_month
    if params[:q].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      @item_id = params[:q][:item_id_eq] if params[:q][:item_id_eq].present?
      if params[:q][:created_at_lteq].present?
        params[:q][:created_at_lteq] =
          params[:q][:created_at_lteq].to_date.end_of_day
      end
    end
    @event = %w[create update destroy]
    @q = PaperTrail::Version.where(item_type: 'SysUser').order('created_at desc').ransack(params[:q])
    @cms_user_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end

  def convert_to_sys_user
    SysUser.find(params[:crm_id]).update(for_crms: false)
    respond_to do |format|
      format.html { redirect_to request.referrer, notice: 'CRM Data was successfully converted to User Data.' }
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
      :for_crms,
      contact_attributes: %i[
        id
        address
        home
        office
        mobile
        fax
        email
        comment
        status
        city_id
        country_id
        sys_user_id
        permanent_address
      ],
      notes_attributes: %i[
        id
        message
        assigned_to_id
        created_by
        notable_id
        notable_type
        _destroy
      ],
      follow_ups_attributes: %i[
        id
        reminder_type
        task_type
        priority
        assigned_to_id
        created_by
        date
        comment
        followable_id
        followable_type
        _destroy
      ],
      cms_data: {}
    )
  end

  def set_sys_user
    @sys_user = SysUser.find(params[:id])
  end

  def download_associated_pdf
    @sys_users = @q.result
    generate_pdf(@sys_users, 'CRM', 'pdf.html', 'A4', false, 'crms/crm_associated_data.pdf.erb')
  end

  def new_edit_data
    @user_types = UserType.all
    @cities = City.all
    @countries = Country.all
    @user_groups = UserGroup.all
    @staff = Staff.where(staff_type: 'active')
    @pos_setting = PosSetting.last
    @project_name = get_setting('project_name')
    @client_type = get_setting('client_type')
    @client_status = get_setting('client_status')
    @category = get_setting('category')
    @deal_stat = get_setting('deal_status')
    @source = get_setting('source')
    created_by_ids = current_user.created_by_ids_list_to_view
    # roles_mask = current_user.allowed_to_view_roles_mask_for
    @users = User.where('company_type=? or created_by_id=?', current_user.company_type, created_by_ids)
  end

  def download_crm_csv_file
    @sys_user = params[:export].present? ? SysUser.all : @q.result
    header_for_csv = %w[Name Agent_name Project_Name Category Client_Status Plot_size Short_Details Created_at]
    data_for_csv = get_data_for_crm_csv
    generate_csv(data_for_csv, header_for_csv, 'CRM')
  end

  def download_crm_pdf_file
    @sys_users = @q.result
    sorted_data
    generate_pdf(@sorted_data.as_json, 'CRM', 'pdf.html', 'A4', false, 'crms/index.pdf.erb')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'crms/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, 'crms')
    flash[:notice] = if params[:email_value].present?
                       "Email has been sent to #{params[:email_value]}"
                     else
                       "Email has been sent to #{current_user.email}"
                     end
    redirect_to crms_path
  end

  def export_file
    @sys_user = SysUser.all
    header_for_csv = %w[id number name agent_id plot_size short_details project_name client_type client_status
                        category deal_status source]
    data_for_csv = get_data_for_crm_export
    generate_csv(data_for_csv, header_for_csv, 'CRM')
  end

  def index_search_data
    @options_for_select = SysUser.all
    created_by_ids = current_user.created_by_ids_list_to_view
    @all_agents = User.where('company_type=? or created_by_id=?', current_user.company_type, created_by_ids).pluck(:name,
                                                                                                                   :id)
    @all_user = SysUser.where(for_crms: [true, nil])
    @all_plot_sizes = SysUser.pluck(:ntn).uniq
    @user_types = UserType.all
    @user_groups = UserGroup.all
    @total_followups = FollowUp.where(followable_type: 'SysUser').group(:followable_id).count
    @follow_up_count = FollowUp.where(created_at: Time.current.all_day).count
  end

  def get_setting(setting_name)
    @pos_setting&.extra_settings&.dig(setting_name)&.map(&:downcase) || []
  end
end

def crm_charts
  @total_agent_count = SysUser.group(:credit_status).count.except(0, nil).sort.to_h
  agent_ids = @total_agent_count.keys
  @agent_name = User.where(id: agent_ids).pluck(:name).map { |a| a.gsub(' ', '-') }
  @agent_count = @total_agent_count.values

  @client_count = SysUser.group("cms_data->'$.client_type'").count.except(nil, '', '""')
  @ct_name = @client_count.keys.map { |a| a.gsub(' ', '-') }
  @ct_type = @client_count.values

  @deal_status_count = SysUser.group("cms_data->'$.deal_status'").where(for_crms: [true, false]).count.except(nil, '', '""')
  @deal_status = @deal_status_count.keys.map { |a| a.gsub(' ', '-') }
  @deal_count = @deal_status_count.values

  @category_count = SysUser.group("cms_data->'$.category'").count.except(nil, '', '""')
  @ctg_name = @category_count.keys.map { |a| a.gsub(' ', '-') }
  @ctg_count = @category_count.values

  @project_count = SysUser.group("cms_data->'$.project_name'").count.except(nil, '', '""')
  @prg_name = @project_count.keys.map { |a| a.gsub(' ', '-') }
  @prg_count = @project_count.values

  @in_process_count = 0
  @closed_count = 0
  @dead_count = 0
  @deal_status_count.each do |a|
    if a.first.include?('dead')
      @dead_count = a[1]
    elsif a.first.include?('closed')
      @closed_count = a[1]
    elsif a.first.include?('process')
      @in_process_count = a[1]
    end
  end
end
