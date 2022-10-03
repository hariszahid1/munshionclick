class SmsController < ApplicationController
  def index
    @l = SmsLog.ransack()
    if @l.result.count > 0
      @l.sorts = 'created_at desc' if @l.sorts.empty?
    end
    @sms_log = @l.result.page(params[:page])
    @customers = SysUser.all
    @q = SysUser.joins(:contact).ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'name asc' if @q.sorts.empty?
    end
    @sys_users = @q.result
    @home =   @sys_users.pluck('home').uniq
    @office = @sys_users.pluck('office').uniq
    @mobile = @sys_users.pluck('mobile').uniq
    @phone = (@mobile+@office+@home).uniq.reject(&:empty?).join(',')
    @sys_users = @sys_users.page(params[:page])


    @departments =Department.all
    @staff = Staff.all
    @p = Staff.ransack(params[:p])
    if @p.result.count > 0
      @p.sorts = 'name asc' if @p.sorts.empty?
    end
    @staffs = @p.result
    @staff_phone = @staffs.pluck('phone').uniq.reject(&:empty?).join(',')
    @staffs = @staffs.page(params[:page])


    if params[:sms_submit].present?
      if params[:sms_to].present?
        send_sms(params[:sms_to],params[:sms_msg],'','')
      else
        redirect_to sms_index_path, notice: 'PLease Past Contacts like 923xxxxxxxxx,923xxxxxxxxx... paste 100 phone number in single request'
      end
    end
    if params[:sms_submit_urdu].present?
      if params[:sms_to].present?
        send_sms(params[:sms_to],params[:sms_msg],'','urdu')
      else
        redirect_to sms_index_path, notice: 'PLease Past Contacts like 923xxxxxxxxx,923xxxxxxxxx... paste 100 phone number in single request'
      end
    end
  end

  def sms_to_staff
    @sms_log = SmsLog.all
    @departments =Department.all
    @customers = Staff.all
    @q = Staff.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'name asc' if @q.sorts.empty?
    end
    @sys_users = @q.result
    @phone = @sys_users.pluck('phone').uniq.reject(&:empty?).join(',')
    @sys_users = @sys_users.page(params[:page])
    if params[:sms_submit].present?
      if params[:sms_to].present?
        send_sms(params[:sms_to],params[:sms_msg],'','')
      end
    end
    if params[:sms_submit_urdu].present?
      if params[:sms_to].present?
        send_sms(params[:sms_to],params[:sms_msg],'','urdu')
      end
    end
  end
end
