class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  before_action :set_paper_trail_whodunnit
  before_action :set_company_type

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
    session[:fourth_referrer]=session[:third_referrer]
    session[:third_referrer]=session[:second_referrer]
    session[:second_referrer]=session[:referrer]
    session[:referrer]=request.referrer
  end
  def get_request_referrer
    return session[:referrer].to_s        if !((request.referrer.to_s.include? "edit")||(request.referrer.to_s.include? "new"))
    return session[:second_referrer].to_s if !((session[:second_referrer].to_s.include? "edit")||(session[:second_referrer].to_s.include? "new"))
    return session[:third_referrer].to_s  if !((session[:third_referrer].to_s.include? "edit")||(session[:third_referrer].to_s.include? "new"))
    return session[:fourth_referrer].to_s if !((session[:fourth_referrer].to_s.include? "edit")||(session[:fourth_referrer].to_s.include? "new"))
    return ""
  end
  def after_sign_in_path_for(resource)
    dashboard_index_path
  end

  def admin_name_on_nav
    pos_setting=PosSetting.first
    return "P-O-S" unless pos_setting.present?
    if pos_setting.present? and pos_setting.display_name?
      pos_setting.display_name
    elsif current_user.super_admin? || current_user.admin?
      current_user.name
    elsif current_user.staff?
      User.find_by(id: current_user.created_by_id).name
    end
  end

  def check_display_name_for_nav(pos_setting)
    return "P-O-S" unless pos_setting.present?
    if pos_setting.present? and pos_setting.display_name?
      pos_setting.display_name
    elsif current_user.super_admin? || current_user.admin?
      current_user.name
    elsif current_user.staff?
      current_user.name
    end
  end

  def pos_expiry_date
    pos_setting=PosSetting.first
    if pos_setting.present? and (pos_setting.expiry_date-10.day)<DateTime.now
      pos_setting.expiry_date.strftime("Soon : %d/%b/%Y at %I:%M%p")
    elsif pos_setting.present? and pos_setting.expiry_date?
      pos_setting.expiry_date.strftime(": %d/%b/%Y at %I:%M%p")
    else
      "Hosting Expiry Date : Unlimted"
    end
  end

  def check_expiry_date(pos_setting)
    if pos_setting.present? and (pos_setting.expiry_date-10.day)<DateTime.now
      pos_setting.expiry_date.strftime("Soon : %d/%b/%Y at %I:%M%p")
    elsif pos_setting.present? and pos_setting.expiry_date?
      pos_setting.expiry_date.strftime(": %d/%b/%Y at %I:%M%p")
    else
      "Hosting Expiry Date : Unlimted"
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
      if pos_setting.sys_type=='batha' or pos_setting.sys_type=='Factory'
        true
      else
        false
      end
    else
      false
    end
  end

  def pos_setting_sys_type
    pos_setting=PosSetting.first
    if pos_setting.present?
      pos_setting.sys_type
    else
      "P-O-S"
    end
  end

  def check_system_type(pos_setting)
    if pos_setting.present?
      pos_setting.sys_type
    else
      "P-O-S"
    end
  end

  def pos_setting_is_qr
    pos_setting = PosSetting.first
    return (pos_setting.present? ? pos_setting.is_qr : false)
  end

  def pos_setting_is_sms
    pos_setting=PosSetting.first
    return (pos_setting.present? ? pos_setting.is_sms : false)
  end

  def pos_setting_display_name
    return "MunshiOnClick" unless PosSetting.first.present?
    return PosSetting.first.display_name
  end

  def check_display_name(pos_setting)
    return "MunshiOnClick" unless pos_setting.present?
    return pos_setting.display_name
  end

  def wicked_image_active_storage_workaround( image )
    if image.is_a? ActiveStorage::Attachment
      save_path = Rails.root.join( "tmp", "#{image.id}.jpg")
      File.open(save_path, 'wb') do |file|
        file << image.blob.download
      end
      return save_path.to_s
    end
  end


  def number_to_words(num)
    numbers_to_name = {
        10000000 => "crore",
        100000 => "lakh",
        1000 => "thousand",
        100 => "hundred",
        90 => "ninety",
        80 => "eighty",
        70 => "seventy",
        60 => "sixty",
        50 => "fifty",
        40 => "forty",
        30 => "thirty",
        20 => "twenty",
        19=>"nineteen",
        18=>"eighteen",
        17=>"seventeen",
        16=>"sixteen",
        15=>"fifteen",
        14=>"fourteen",
        13=>"thirteen",
        12=>"twelve",
        11 => "eleven",
        10 => "ten",
        9 => "nine",
        8 => "eight",
        7 => "seven",
        6 => "six",
        5 => "five",
        4 => "four",
        3 => "three",
        2 => "two",
        1 => "one"
      }

    log_floors_to_ten_powers = {
      0 => 1,
      1 => 10,
      2 => 100,
      3 => 1000,
      4 => 1000,
      5 => 100000,
      6 => 100000,
      7 => 10000000
    }

    num = num.to_i
    return '' if num <= 0 or num >= 100000000

    log_floor = Math.log(num, 10).floor
    ten_power = log_floors_to_ten_powers[log_floor]

    if num <= 20
      numbers_to_name[num]
    elsif log_floor == 1
      rem = num % 10
      [ numbers_to_name[num - rem], number_to_words(rem) ].join(' ')
    else
      [ number_to_words(num / ten_power), numbers_to_name[ten_power], number_to_words(num % ten_power) ].join(' ')
    end
  end

    def send_sms(to,msg,redirect_url,type)
      if(type=="urdu")
        send_sms_urdu(to,msg,redirect_url)
      else
        send_sms_english(to,msg,redirect_url)
      end
    end

    def send_sms_english(to,msg,redirect_url)
      @pos_setting = PosSetting.last
      msg = @pos_setting&.sms_templates["sms_header"].to_s + msg.to_s + @pos_setting&.sms_templates["sms_footer"].to_s
      if @pos_setting.is_sms.present? && to.present?
        sms_user = @pos_setting.sms_user
        sms_pass = @pos_setting.sms_pass
        sms_mask = @pos_setting.sms_mask
        msg = ERB::Util.url_encode(msg)
        sms_mask_erb = ERB::Util.url_encode(sms_mask)
        # request='http://my.ezeee.pk/sendsms_url.html?Username='+sms_user+'&Password='+sms_pass+'&From='+ERB::Util.url_encode(sms_mask)+'&To='+to+'&Message='+msg.to_s
        # response = HTTParty.get(request)
        SmsJob.perform_later(sms_user,sms_pass,sms_mask_erb,to,msg)
        SmsLog.create(sms_from: sms_mask,sms_to: to, msg: msg,sms_by: current_user.user_name,response: response.body)
      end
    end

    def send_sms_urdu(to,msg,redirect_url)
      @pos_setting = PosSetting.last
      msg = @pos_setting&.sms_templates["sms_header"].to_s + msg.to_s + @pos_setting&.sms_templates["sms_footer"].to_s
      if @pos_setting.is_sms.present? && to.present?
        sms_user = @pos_setting.sms_user
        sms_pass = @pos_setting.sms_pass
        sms_mask = @pos_setting.sms_mask
        msg = ERB::Util.url_encode(msg)
        sms_mask_erb = ERB::Util.url_encode(sms_mask)
        SmsJob.perform_later(sms_user,sms_pass,sms_mask_erb,to,msg)
        SmsLog.create(sms_from: sms_mask,sms_to: to, msg: msg,sms_by: current_user.user_name,response: response.body)
      end
    end

  def print_pdf(pdf_title, pdf_layout,page_size,html=false,orientation='Portrait')
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
            margin_left: @pos_setting&.pdf_margin_left.to_f,
          },
          encoding: "UTF-8",
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
          :page_height => '1.2in',
          :page_width => '1.6in',
          encoding: "UTF-8",
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

  def set_company_type
    if current_user.present?
      RequestStore.store[:company_type] = current_user.superAdmin.company_type if current_user.superAdmin.present?
    elsif params[:receivable].present?
      RequestStore.store[:company_type] = params[:receivable].to_s
    end
    ApplicationRecord.set_connection

    @pos_setting = PosSetting.last
		if (current_user.present? && current_user.permission_updated.blank?)
			cookies[:test]=JSON.generate "devbox22"
			puts"--------------------------------------------------MB cookies of current user is updated"
			temp = User.joins(:user_permissions).includes(:user_permissions).find_by(id: current_user.id)
			cookies[:can_create]= "{\"accounts\":true,\"cities\":true,\"compaigns\":true,\"contacts\":true,\"countries\":true,\"daily_books\":true,\"daily_sales\":true,\"dashboard\":true,\"departments\":true,\"expense_entries\":true,\"expense_types\":true,\"expenses\":true,\"gates\":true,\"helps\":true,\"home\":true,\"investments\":true,\"item_types\":true,\"items\":true,\"ledger_books\":true,\"logs\":true,\"map_columns\":true,\"materials\":true,\"order_items\":true,\"orders\":true,\"payments\":true,\"pos_settings\":true,\"product_categories\":true,\"product_stock_excahanges\":true,\"product_stocks\":true,\"product_sub_categories\":true,\"product_warranties\":true,\"production_block_types\":true,\"production_blocks\":true,\"production_cycles\":true,\"productions\":true,\"products\":true,\"property_plans\":true,\"purchase_sale_details\":true,\"purchase_sale_items\":true,\"raw_products\":true,\"remarks\":true,\"reports\":true,\"salaries\":true,\"salary_details\":true,\"sms\":true,\"staff_deals\":true,\"staff_ledger_books\":true,\"staff_raw_products\":true,\"staffs\":true,\"sys_users\":true,\"sys_users/customer\":true,\"sys_users/supplier\":true,\"sys_users/own\":true,\"user_types\":true,\"users\":true,\"warranties\":true,\"user_groups\":true,\"customer_management_systems\":true}"
			# cookies[:can_read]= JSON.generate temp.user_permissions.pluck(:module,:can_read).to_h
			# cookies[:can_update]= JSON.generate temp.user_permissions.pluck(:module,:can_update).to_h
			# cookies[:can_delete]= JSON.generate temp.user_permissions.pluck(:module,:can_delete).to_h
			# cookies[:can_accessed]= JSON.generate temp.user_permissions.pluck(:module,:can_accessed).to_h
			# cookies[:is_hidden]= JSON.generate temp.user_permissions.pluck(:module,:is_hidden).to_h
			# cookies[:can_download_csv]= JSON.generate temp.user_permissions.pluck(:module,:can_download_csv).to_h
			# cookies[:can_download_pdf]= JSON.generate temp.user_permissions.pluck(:module,:can_download_pdf).to_h
			# cookies[:can_import_export]= JSON.generate temp.user_permissions.pluck(:module,:can_import_export).to_h
			# cookies[:can_send_email]= JSON.generate temp.user_permissions.pluck(:module,:can_send_email).to_h
			# session[:is_hidden]=temp.user_permissions.pluck(:module,:is_hidden).to_h
			# session[:can_accessed]=temp.user_permissions.pluck(:module,:can_accessed).to_h
			# session[:can_create]=temp.user_permissions.pluck(:module,:can_create).to_h
			# session[:can_read]=temp.user_permissions.pluck(:module,:can_read).to_h
			# session[:can_update]=temp.user_permissions.pluck(:module,:can_update).to_h
			# session[:can_delete]=temp.user_permissions.pluck(:module,:can_delete).to_h
			# session[:can_download_csv]=temp.user_permissions.pluck(:module,:can_download_csv).to_h
			# session[:can_download_pdf]=temp.user_permissions.pluck(:module,:can_download_pdf).to_h
			# session[:can_import_export]=temp.user_permissions.pluck(:module,:can_import_export).to_h
			# session[:can_send_email]=temp.user_permissions.pluck(:module,:can_send_email).to_h
			current_user.update(permission_updated: true)
		end

    if @pos_setting.present?
      @account_balance = Account.group(:title).sum(:amount)
      @account_amount_total = Account.sum(:amount)
      @sys_user_payable_group_total=SysUser.where('balance > 0').sum(:balance)
      @sys_user_receiveable_group_total=SysUser.where('balance < 0').sum(:balance)
      @staff_payable_group_total=Staff.where('balance>0').where(deleted: false).sum(:balance)
      @staff_reciveable_group_total=Staff.where('balance<0').where(deleted: false).sum(:balance)
      @sale_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Sale').sum(:total_sale_price)
      @expense_total = ExpenseEntry.sum(:amount)
      @investments = Investment.sum(:invest)
      @purchase_sale_detail_discount_list = PurchaseSaleDetail.where(transaction_type:'Sale').where.not(discount_price:[nil,0]).sum(:discount_price)
      @credit_salary =     SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id:nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).sum(:amount).to_f
      if @pos_setting.sys_type=='batha'
        @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id>=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      else
        @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      end

      @credit_salary =     SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id:nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).sum(:amount).to_f
      @purchase_item_total = PurchaseSaleItem.joins(:item).where(transaction_type:'Purchase').sum(:total_cost_price)
      @purchase_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Purchase').sum(:total_cost_price)

      @total_payable=@sys_user_payable_group_total+@staff_payable_group_total+@sale_product_total
      @total_reciveable=@sys_user_receiveable_group_total.abs+@staff_reciveable_group_total.abs+@expense_total+@investments+@salary_detail_total+@credit_salary+@purchase_sale_detail_discount_list+@purchase_item_total+@purchase_product_total
    end
  end


  def delete_image_attachment
    @image = ActiveStorage::Blob.find_signed(params[:id])
    @image.attachments.first.purge_later
    redirect_back(fallback_location: request.referer)
  end

	def check_can_create(temp_module)
		# if temp_module=='cities'
		# 	temp=JSON.parse cookies[:can_create]
		# 	return temp[temp_module]
		# else
		# 	return true
		# end
		return true

	end
	def check_can_read(temp_module)
		# if temp_module=='cities'
		# 	temp=JSON.parse cookies[:can_read]
		# 	return temp[temp_module]
		# else
		# 	return true
		# end
		return true


	end
	def check_can_update(temp_module)
		# if temp_module=='cities'
		# 	temp=JSON.parse cookies[:can_update]
		# 	return temp[temp_module]
		# else
		# 	return true
		# end
		return true

	end
	def check_can_delete(temp_module)
		# if temp_module=='cities'
		# 	temp=JSON.parse cookies[:can_delete]
		# 	return temp[temp_module]
		# else
		# 	return true
		# end
		return true

	end
	def check_can_download_csv(temp_module)
		# if temp_module=='cities'
		# 	temp=JSON.parse cookies[:can_download_csv]
		# 	return temp[temp_module]
		# else
		# 	return true
		# end
		return true

	end
	def check_can_download_pdf(temp_module)
		# if temp_module=='cities'
		# 	temp=JSON.parse cookies[:can_download_pdf]
		# 	return temp[temp_module]
		# else
		# 	return true
		# end
		return true

	end
	def check_can_accessed(temp_module)
		# if temp_module=='cities'
		# 	temp=JSON.parse cookies[:can_accessed]
		# 	return temp[temp_module]
		# else
		# 	return true
		# end
		return true

	end
	def check_is_hidden(temp_module)
		# if temp_module=='cities'
		# 	temp=JSON.parse cookies[:is_hidden]
		# 	return temp[temp_module]
		# else
		# 	return false
		# end
		return false

	end
	def check_can_import_export(temp_module)
		# if temp_module=='cities'
		# 	temp=JSON.parse cookies[:can_import_export]
		# 	return temp[temp_module]
		# else
		# 	return true
		# end

		return true

	end	
	def check_can_send_email(temp_module)
		# if temp_module=='cities'
		# 	temp=JSON.parse cookies[:can_send_email]
		# 	return temp[temp_module]
		# else
		# 	return true
		# end
		return true

	end	

	def check_access
		if (check_is_hidden("#{controller_name}"))
			respond_to do |format|
				format.html { redirect_to dashboard_path, alert: "Your system does not have this module" }
			end
		else
			if (check_can_accessed("#{controller_name}")==false)
				respond_to do |format|
					format.html { redirect_to dashboard_path, alert: "you are not authorized." }
				end
			end
		end	
	end
end
