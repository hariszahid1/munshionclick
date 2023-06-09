class SysUsersController < ApplicationController
  include SysUsersCsvMethods
  include PdfCsvGeneralMethod
  include SysUsersHelper

  before_action :check_access, only: %i[index show edit update destroy]
  before_action :set_sys_user, only: %i[show edit update destroy]

  # GET /sys_users
  # GET /sys_users.json
  def index
    @q = SysUser.order('name asc').where(for_crms: [false, nil]).ransack(params[:q])
    @sys_users = @q.result.page(params[:page])
    @sys_user_balance = @q.result.sum(:balance).to_f.round(2)
    @all_user = SysUser.where(for_crms: [false, nil]).all
    @user_types = UserType.all

    download_sys_users_csv_file if params[:csv].present?
    download_sys_users_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
    @count_sys_user = SysUser.all.group(:user_group).count
    @count_status = SysUser.all.group(:status).count

    @user_count = []
    @user_count.push(SysUser.where('balance > 0').count)
    @user_count.push(SysUser.where('balance < 0').count)
    @user_count.push(SysUser.where('balance = 0').count)

    @user_group_title = @count_sys_user.keys
    @user_group_count = @count_sys_user.values
    @status_title = @count_status.keys
    @status_count = @count_status.values

    @total_cities_count = Contact.joins(:city).group('cities.title').count
    @city_title = @total_cities_count.keys.map { |a| a.gsub(' ', '-') }
    @city_user = @total_cities_count.values

    @balance_sum = []
    @balance_sum.push(SysUser.where('balance > 0').sum(:balance).to_f)
    @balance_sum.push(SysUser.where('balance < 0').sum(:balance).to_f)
  end

  # GET /sys_users/1
  # GET /sys_users/1.json
  def show
    @user_types = UserType.all
    @cities = City.all
    @countries = Country.all

    respond_to do |format|
      format.js
    end
  end

  def update_balance
    sys_user = SysUser.find(params[:id])
    @credit_sum = LedgerBook.where(sys_user_id: sys_user).sum(:credit)
    @debit_sum = LedgerBook.where(sys_user_id: sys_user).sum(:debit)
    @updated_balance = @credit_sum.to_f - @debit_sum.to_f
    sys_user.update(balance: @updated_balance)
    render json: { updated_balance: @updated_balance }
  end

  def payable
    @q = SysUser.where('balance > 0 ').ransack(params[:q])
    @q.sorts = 'name asc' if @q.result.count > 0 && @q.sorts.empty?
    @sys_users = @q.result(distinct: true)
    @all_user = SysUser.all
    @user_types = UserType.all
    if params[:submit_pdf_staff_with].present?
      @q.sorts = 'name desc' if @q.result.count > 0 && @q.sorts.empty?
      print_pdf('index_staff_wise', 'pdf.html', 'A4')
    elsif params[:submit_csv_staff_with]
      createCSV
    end
  end

  def receiveable
    @q = SysUser.where('balance < 0 ').ransack(params[:q])
    @q.sorts = 'name asc' if @q.result.count > 0 && @q.sorts.empty?
    if params[:q].present?
      @code = params[:q][:code]
      @cnic = params[:q][:cnic]
      @name = params[:q][:name_or_code_cont]
      @user_type = params[:q][:user_type]
      @user_group = params[:q][:user_group_eq]
      @contact = params[:q][:contact]
      @status = params[:q][:status]
      @occupation = params[:q][:occupation]
      @credit_status = params[:q][:credit_status]
      @credit_limit = params[:q][:credit_limit]
      @opening_balance = params[:q][:opening_balance]
    end
    @sys_users = @q.result(distinct: true)

    @all_user = SysUser.all
    @user_types = UserType.all
    if params[:submit_pdf_staff_with].present?
      @q.sorts = 'name desc' if @q.result.count > 0 && @q.sorts.empty?
      print_pdf('index_staff_wise', 'pdf.html', 'A4')
    elsif params[:submit_csv_sys_user_receivable].present?
      createCSV
    end
  end

  def customer
    check_access_of('sys_users/customer')
    @sys_user_all = SysUser.where(user_group: ['Customer'])
    @q = SysUser.where(user_group: ['Customer']).ransack(params[:q])
    @q.sorts = 'id asc' if @q.result.count > 0 && @q.sorts.empty?
    @name = params[:q][:name_or_code_cont] if params[:q].present?
    @sys_users = @q.result
    @user_types = UserType.all
    if params[:submit_pdf_staff_with].present?
      @q.sorts = 'created_at desc' if @q.result.count > 0 && @q.sorts.empty?
      @sys_users_pdf = @q.result
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
                 layout: 'pdf.html',
                 page_size: 'A4',
                 margin_top: '0',
                 margin_right: '0',
                 margin_bottom: '0',
                 margin_left: '0',
                 footer: {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                   right: '[page] of [topage]'
                 },
                 encoding: 'UTF-8',
                 show_as_html: false
        end
      end
    end
  end

  def supplier
    check_access_of('sys_users/supplier')
    @sys_user_all = SysUser.where(user_group: ['Supplier'])
    @q = SysUser.where(user_group: ['Supplier']).ransack(params[:q])
    @q.sorts = 'id asc' if @q.result.count > 0 && @q.sorts.empty?
    @name = params[:q][:name_or_code_cont] if params[:q].present?
    @sys_users = @q.result
    @user_types = UserType.all
    if params[:submit_pdf_staff_with].present?
      @q.sorts = 'created_at desc' if @q.result.count > 0 && @q.sorts.empty?
      @sys_users_pdf = @q.result
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
                 layout: 'pdf.html',
                 page_size: 'A4',
                 margin_top: '0',
                 margin_right: '0',
                 margin_bottom: '0',
                 margin_left: '0',
                 encoding: 'UTF-8',
                 footer: {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                   right: '[page] of [topage]'
                 },
                 show_as_html: false
        end
      end
    end
  end

  def own
    check_access_of('sys_users/own')
    @sys_user_all = SysUser.where(user_group: ['Own'])
    @q = SysUser.where(user_group: ['Own']).ransack(params[:q])
    @q.sorts = 'id asc' if @q.result.count > 0 && @q.sorts.empty?
    @name = params[:q][:name_or_code_cont] if params[:q].present?
    @sys_users = @q.result
    @user_types = UserType.all
    if params[:submit_pdf_staff_with].present?
      @q.sorts = 'created_at desc' if @q.result.count > 0 && @q.sorts.empty?
      @sys_users_pdf = @q.result
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
                 layout: 'pdf.html',
                 page_size: 'A4',
                 margin_top: '0',
                 margin_right: '0',
                 margin_bottom: '0',
                 margin_left: '0',
                 footer: {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                   right: '[page] of [topage]'
                 },
                 encoding: 'UTF-8',
                 show_as_html: false
        end
      end
    end
  end

  # GET /sys_users/new
  def new
    @user_types = UserType.all
    @sys_user = SysUser.new
    @cities = City.all
    @countries = Country.all
    @staff = Staff.all
    @sys_user.notes.build
    @sys_user.build_contact
    @sys_user.follow_ups.build
  end

  # GET /sys_users/1/edit
  def edit
    @user_types = UserType.all
    @cities = City.all
    @countries = Country.all
    @staff = Staff.all
  end

  # POST /sys_users
  # POST /sys_users.json
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

  # PATCH/PUT /sys_users/1
  # PATCH/PUT /sys_users/1.json
  def update
    if params[:order_id] && params[:commit]
      Order.find(params[:order_id]).remarks.new(body: sys_user_params[:name],
                                                message: current_user.name + ' - ' + current_user.user_name, comment: @sys_user.name, remark_type: 'Transfer').save!
    end
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

  # DELETE /sys_users/1
  # DELETE /sys_users/1.json
  def destroy
    @sys_user.destroy!
    respond_to do |format|
      format.html { redirect_to sys_users_path, notice: 'Sys User was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @sys_user }
    end
  end

  # GET /sys_users/1
  # GET /sys_users/1.json
  def sys_user_balance
    sys_user = SysUser.find(params[:sys_user_id])
    respond_to do |format|
      format.json { render json: { status: 'success', balance: sys_user.balance }, status: :ok }
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
    @sys_user_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_sys_user
    @sys_user = SysUser.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
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
      :suffix,
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
        contactable_type
        contactable_id
        date_of_birth
      ],
      notes_attributes: %i[
        id
        message
        assigned_to_id
        created_by
        notable_id
        notable_type
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
      ],
      cms_data: {}
    )
  end

  def createCSV
    if params[:submit_csv_staff_with].present?
      csv_data = payable_csv
    elsif params[:submit_csv_sys_user_receivable].present?
      puts '-------------------------'
      csv_data = receiveable_csv
    end
    request.format = 'csv'
    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: "index_staff_wise - #{Date.today}.csv" }
    end
  end

  def download_sys_users_csv_file
    @sys_users = @q.result
    if pos_setting_sys_type.eql? 'CustomClear'
      header_for_csv = %w[id code name user_type user_group status occupation credit_status credit_limit balance]
      data_for_csv = get_data_for_sys_users_custom_clear_csv
    else
      header_for_csv = %w[id code name user_group status occupation opening_balance balance jama_benam address]
      data_for_csv = get_data_for_sys_users_csv
    end
    generate_csv(data_for_csv, header_for_csv,
                 "Sys-users-Total-#{@sys_users.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
  end

  def download_sys_users_pdf_file
    sort_data_according
    generate_pdf(@sorted_data.as_json, "Sys-users-Total-#{@sorted_data.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}",
                 'pdf.html', 'A4', false, 'sys_users/index.pdf.erb')
  end

  def send_email_file
    sort_data_according
    EmailJob.perform_later(@sorted_data.as_json, 'sys_users/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "Sys-users-Total-#{@sorted_data.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
    flash[:notice] = if params[:email_value].present?
                       "Email has been sent to #{params[:email_value]}"
                     else
                       "Email has been sent to #{current_user.email}"
                     end
    redirect_to sys_users_path
  end

  def sort_data_according
    @sorted_data = []
    data = params[:pdf] == 'without_jama_benam_pdf' ? @q.result.where.not(balance: 0) : @q.result
    if pos_setting_sys_type.eql? 'CustomClear'
      data.each do |d|
        @sorted_data << {
          id: d.id,
          code: d.code,
          name: d.name,
          user_type: d.user_type&.title,
          user_group: d.user_group,
          status: d.status,
          occupation: d.occupation,
          credit_status: d.credit_status.to_f.round(2),
          credit_limit: d.credit_limit.to_f.round(2),
          balance: d.balance.to_f.round(2)
        }
      end
    else
      data.each do |d|
        @sorted_data << {
          id: d.id,
          code: d.code,
          name: d.name,
          user_group: d.user_group,
          status: d.status,
          occupation: d.occupation,
          opening_balance: d.opening_balance.to_f.round(2),
          balance: d.balance.to_f.round(2),
          jama_benam: if d.balance.to_f.zero?
                        'Nill'
                      else
                        d.balance.to_f.positive? ? 'Jama' : 'Benam'
                      end,
          address: d.contact&.city&.title
        }
      end
    end
  end

  def export_file
    export_data('SysUser')
  end

  def check_access_of(tempModule)
    if check_is_hidden(tempModule.to_s)
      respond_to do |format|
        format.html { redirect_to dashboard_path, alert: 'Your system does not have this module' }
      end
    elsif check_can_accessed(tempModule.to_s) == false
      respond_to do |format|
        format.html { redirect_to dashboard_path, alert: 'you are not authorized.' }
      end
    end
  end
end
