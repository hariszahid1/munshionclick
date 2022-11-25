class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  before_action :set_paper_trail_whodunnit
  before_action :set_company_type
  before_action :default_accees
  after_action :set_request_referrer
  before_action :get_request_referrer

  include PublicActivity::StoreController

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to dashboard_url, alert: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  def set_request_referrer
    session[:fourth_referrer] = session[:third_referrer]
    session[:third_referrer] = session[:second_referrer]
    session[:second_referrer] = session[:referrer]
    session[:referrer] = request.referrer
  end

  def get_request_referrer
    unless (request.referrer.to_s.include? 'edit') || (request.referrer.to_s.include? 'new')
      return session[:referrer].to_s
    end
    unless (session[:second_referrer].to_s.include? 'edit') || (session[:second_referrer].to_s.include? 'new')
      return session[:second_referrer].to_s
    end
    unless (session[:third_referrer].to_s.include? 'edit') || (session[:third_referrer].to_s.include? 'new')
      return session[:third_referrer].to_s
    end
    unless (session[:fourth_referrer].to_s.include? 'edit') || (session[:fourth_referrer].to_s.include? 'new')
      return session[:fourth_referrer].to_s
    end

    ''
  end

  def after_sign_in_path_for(_resource)
    dashboard_index_path
  end

  def admin_name_on_nav
    pos_setting = PosSetting.first
    return 'P-O-S' unless pos_setting.present?

    if pos_setting.present? and pos_setting.display_name?
      pos_setting.display_name
    elsif current_user.super_admin? || current_user.admin?
      current_user.name
    elsif current_user.staff?
      User.find_by(id: current_user.created_by_id).name
    end
  end

  def check_display_name_for_nav(pos_setting)
    return 'P-O-S' unless pos_setting.present?

    if pos_setting.present? and pos_setting.display_name?
      pos_setting.display_name
    elsif current_user.super_admin? || current_user.admin?
      current_user.name
    elsif current_user.staff?
      current_user.name
    end
  end

  def pos_expiry_date
    pos_setting = PosSetting.first
    if pos_setting.present? and (pos_setting.expiry_date - 10.day) < DateTime.now
      pos_setting.expiry_date.strftime('Soon : %d/%b/%Y at %I:%M%p')
    elsif pos_setting.present? and pos_setting.expiry_date?
      pos_setting.expiry_date.strftime(': %d/%b/%Y at %I:%M%p')
    else
      'Hosting Expiry Date : Unlimted'
    end
  end

  def check_expiry_date(pos_setting)
    if pos_setting.present? and (pos_setting.expiry_date - 10.day) < DateTime.now
      pos_setting.expiry_date.strftime('Soon : %d/%b/%Y at %I:%M%p')
    elsif pos_setting.present? and pos_setting.expiry_date?
      pos_setting.expiry_date.strftime(': %d/%b/%Y at %I:%M%p')
    else
      'Hosting Expiry Date : Unlimted'
    end
  end

  def super_admin_company_name
    if current_user&.super_admin?
      current_user.company_type
    else
      current_user&.superAdmin&.company_type
    end
  end

  def pos_type_batha
    pos_setting = PosSetting.first
    if pos_setting.present?
      if pos_setting.sys_type == 'batha' or pos_setting.sys_type == 'Factory'
        true
      else
        false
      end
    else
      false
    end
  end

  def pos_setting_sys_type
    pos_setting = PosSetting.first
    if pos_setting.present?
      pos_setting.sys_type
    else
      'P-O-S'
    end
  end

  def check_system_type(pos_setting)
    if pos_setting.present?
      pos_setting.sys_type
    else
      'P-O-S'
    end
  end

  def pos_setting_is_qr
    pos_setting = PosSetting.first
    (pos_setting.present? ? pos_setting.is_qr : false)
  end

  def pos_setting_is_sms
    pos_setting = PosSetting.first
    (pos_setting.present? ? pos_setting.is_sms : false)
  end

  def pos_setting_display_name
    return 'MunshiOnClick' unless PosSetting.first.present?

    PosSetting.first.display_name
  end

  def check_display_name(pos_setting)
    return 'MunshiOnClick' unless pos_setting.present?

    pos_setting.display_name
  end

  def wicked_image_active_storage_workaround(image)
    if image.is_a? ActiveStorage::Attachment
      save_path = Rails.root.join('tmp', "#{image.id}.jpg")
      File.open(save_path, 'wb') do |file|
        file << image.blob.download
      end
      save_path.to_s
    end
  end

  def number_to_words(num)
    numbers_to_name = {
      10_000_000 => 'crore',
      100_000 => 'lakh',
      1000 => 'thousand',
      100 => 'hundred',
      90 => 'ninety',
      80 => 'eighty',
      70 => 'seventy',
      60 => 'sixty',
      50 => 'fifty',
      40 => 'forty',
      30 => 'thirty',
      20 => 'twenty',
      19 => 'nineteen',
      18 => 'eighteen',
      17 => 'seventeen',
      16 => 'sixteen',
      15 => 'fifteen',
      14 => 'fourteen',
      13 => 'thirteen',
      12 => 'twelve',
      11 => 'eleven',
      10 => 'ten',
      9 => 'nine',
      8 => 'eight',
      7 => 'seven',
      6 => 'six',
      5 => 'five',
      4 => 'four',
      3 => 'three',
      2 => 'two',
      1 => 'one'
    }

    log_floors_to_ten_powers = {
      0 => 1,
      1 => 10,
      2 => 100,
      3 => 1000,
      4 => 1000,
      5 => 100_000,
      6 => 100_000,
      7 => 10_000_000
    }

    num = num.to_i
    return '' if num <= 0 or num >= 100_000_000

    log_floor = Math.log(num, 10).floor
    ten_power = log_floors_to_ten_powers[log_floor]

    if num <= 20
      numbers_to_name[num]
    elsif log_floor == 1
      rem = num % 10
      [numbers_to_name[num - rem], number_to_words(rem)].join(' ')
    else
      [number_to_words(num / ten_power), numbers_to_name[ten_power], number_to_words(num % ten_power)].join(' ')
    end
  end

  def send_sms(to, msg, redirect_url, type)
    if type == 'urdu'
      send_sms_urdu(to, msg, redirect_url)
    else
      send_sms_english(to, msg, redirect_url)
    end
  end

  def send_sms_english(to, msg, _redirect_url)
    @pos_setting = PosSetting.last
    msg = @pos_setting&.sms_templates['sms_header'].to_s + msg.to_s + @pos_setting&.sms_templates['sms_footer'].to_s
    if @pos_setting.is_sms.present? && to.present?
      sms_user = @pos_setting.sms_user
      sms_pass = @pos_setting.sms_pass
      sms_mask = @pos_setting.sms_mask
      msg = ERB::Util.url_encode(msg)
      sms_mask_erb = ERB::Util.url_encode(sms_mask)
      # request='http://my.ezeee.pk/sendsms_url.html?Username='+sms_user+'&Password='+sms_pass+'&From='+ERB::Util.url_encode(sms_mask)+'&To='+to+'&Message='+msg.to_s
      # response = HTTParty.get(request)
      SmsJob.perform_later(sms_user, sms_pass, sms_mask_erb, to, msg)
      SmsLog.create(sms_from: sms_mask, sms_to: to, msg: msg, sms_by: current_user.user_name, response: response.body)
    end
  end

  def send_sms_urdu(to, msg, _redirect_url)
    @pos_setting = PosSetting.last
    msg = @pos_setting&.sms_templates['sms_header'].to_s + msg.to_s + @pos_setting&.sms_templates['sms_footer'].to_s
    if @pos_setting.is_sms.present? && to.present?
      sms_user = @pos_setting.sms_user
      sms_pass = @pos_setting.sms_pass
      sms_mask = @pos_setting.sms_mask
      msg = ERB::Util.url_encode(msg)
      sms_mask_erb = ERB::Util.url_encode(sms_mask)
      SmsJob.perform_later(sms_user, sms_pass, sms_mask_erb, to, msg)
      SmsLog.create(sms_from: sms_mask, sms_to: to, msg: msg, sms_by: current_user.user_name, response: response.body)
    end
  end

  def print_pdf(pdf_title, pdf_layout, page_size, html = false, orientation = 'Portrait')
    @pos_setting = PosSetting.first

    request.format = 'pdf'

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: pdf_title,
               layout: pdf_layout,
               page_size: page_size,
               orientation: orientation,
               margin: {
                 margin_top: @pos_setting&.pdf_margin_top.to_f,
                 margin_right: @pos_setting&.pdf_margin_right.to_f,
                 margin_bottom: @pos_setting&.pdf_margin_bottom.to_f,
                 margin_left: @pos_setting&.pdf_margin_left.to_f
               },
               encoding: 'UTF-8',
               footer: {
                 right: '[page] of [topage]'
               },
               show_as_html: html
      end
    end
  end

  def print_barcode(pdf_title)
    request.format = 'pdf'
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: pdf_title,
               page_height: '1.2in',
               page_width: '1.6in',
               encoding: 'UTF-8',
               show_as_html: false
      end
    end
  end
  helper_method :wicked_image_active_storage_workaround
  helper_method :admin_name_on_nav
  helper_method :check_display_name_for_nav
  helper_method :super_admin_company_name
  helper_method :pos_setting_sys_type
  helper_method :check_system_type
  helper_method :pos_setting_is_qr
  helper_method :pos_setting_is_sms
  helper_method :pos_setting_display_name
  helper_method :check_display_name
  helper_method :pos_expiry_date
  helper_method :check_expiry_date
  helper_method :number_to_words
  helper_method :send_sms
  helper_method :send_sms_english
  helper_method :send_sms_urdu

  helper_method :check_can_create
  helper_method :check_can_read
  helper_method :check_can_update
  helper_method :check_can_delete
  helper_method :check_can_download_csv
  helper_method :check_can_download_pdf
  helper_method :check_can_accessed
  helper_method :check_is_hidden
  helper_method :check_can_import_export
  helper_method :check_can_send_email
  helper_method :check_is_hidden_by_module

  def set_company_type
    if current_user.present?
      RequestStore.store[:company_type] = current_user.superAdmin.company_type if current_user.superAdmin.present?
    elsif params[:receivable].present?
      RequestStore.store[:company_type] = params[:receivable].to_s
    end
    ApplicationRecord.set_connection

    @pos_setting = PosSetting.last
    @account_balance = Account.group(:title).sum(:amount)
    @account_amount_total = Account.sum(:amount)
    @total_cash = @pos_setting&.cash_in_hand
  end

  def delete_image_attachment
    @image = ActiveStorage::Blob.find_signed(params[:id])
    @image.attachments.first.purge_later
    redirect_back(fallback_location: request.referer)
  end

  def check_can_create(temp_module)
    return true if temp_module.can_create == true

    false
  end

  def check_can_read(temp_module)
    return true if temp_module.can_read == true

    false
  end

  def check_can_update(temp_module)
    return true if temp_module.can_update == true

    false
  end

  def check_can_delete(temp_module)
    return true if temp_module.can_delete == true

    false
  end

  def check_can_download_csv(temp_module)
    return true if temp_module.can_download_csv == true

    false
  end

  def check_can_download_pdf(temp_module)
    return true if temp_module.can_download_pdf == true

    false
  end

  def check_can_accessed(temp_module)
    return false if temp_module.can_accessed == true

    true
  end

  def check_is_hidden(temp_module)
    return false if temp_module.is_hidden == false

    true
  end

  def check_can_import_export(temp_module)
    return true if temp_module.can_import_export == true

    false
  end

  def check_can_send_email(temp_module)
    return true if temp_module.can_send_email == true

    false
  end

  def default_accees
    # All Permission of Current User
    @all_permissions = User.eager_load(:user_permissions).find(current_user.id).user_permissions if current_user.present?
  end

  def check_access
    # Current User Current Module Permission
    @module_permission = @all_permissions.select(:id, :can_create, :can_update, :can_read, :can_delete, :can_accessed,
                                                 :is_hidden, :can_download_pdf, :can_download_csv, :can_send_email, :can_import_export).find_by(module: controller_name)

    if check_is_hidden(@module_permission) # False
      respond_to do |format|
        format.html do
          redirect_to dashboard_path, alert: 'Your system does not have this module'
        end
      end
    elsif check_can_accessed(@module_permission) # True
      respond_to { |format| format.html { redirect_to dashboard_path, alert: 'you are not authorized.' } }
    end
  end

  def check_is_hidden_by_module(temp_module)
    # All Permission of Current User
    # @all_permissions = User.eager_load(:user_permissions).find(current_user.id).user_permissions
    # Current User Current Module Permission
    @module_permission = @all_permissions.select(:id, :can_create, :can_update, :can_read, :can_delete, :can_accessed,
                                                 :is_hidden, :can_download_pdf, :can_download_csv, :can_send_email, :can_import_export).find_by(module: temp_module)

    return false if check_is_hidden(@module_permission) || check_can_accessed(@module_permission) # True
    return true if !check_is_hidden(@module_permission) || !check_can_accessed(@module_permission)
  end
end
