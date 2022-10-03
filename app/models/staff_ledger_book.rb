class StaffLedgerBook < ApplicationRecord
  belongs_to :staff, optional: true
  belongs_to :salary, optional: true
  belongs_to :salary_detail, optional: true

  after_create :sys_user_balance_change
  after_update :sys_user_balance_change
  after_destroy :sys_user_balance_change

  after_create :sms_on_create

  has_paper_trail ignore: [:updated_at]

  def sys_user_balance_change
    balance = (self&.staff&.staff_ledger_books.sum(:credit).to_f-self&.staff&.staff_ledger_books.sum(:debit).to_f)
    self.staff.update(balance: balance)
  end
  def sms_on_create
    to = self.staff.phone
    @pos_setting = PosSetting.last
    if to.present? && @pos_setting.is_sms.present?
      msg = ""
      if @pos_setting&.sms_templates.present?
        msg = msg + @pos_setting&.sms_templates["staff_new_ledger_credit"].to_s if self.credit.to_f>0 && @pos_setting&.sms_templates["staff_new_ledger_credit"].present?
        msg = msg + @pos_setting&.sms_templates["staff_new_ledger_debit"].to_s if self.debit.to_f>0 && @pos_setting&.sms_templates["staff_new_ledger_debit"].present?
      end
      msg = @pos_setting&.sms_templates["sms_header"].to_s + msg.to_s + @pos_setting&.sms_templates["sms_footer"].to_s
      sms_user = @pos_setting.sms_user
      sms_pass = @pos_setting.sms_pass
      sms_mask = @pos_setting.sms_mask
      msg = ERB::Util.url_encode(msg)
      request='http://my.ezeee.pk/sendsms_url.html?Username='+sms_user+'&Password='+sms_pass+'&From='+ERB::Util.url_encode(sms_mask)+'&To='+to+'&Message='+msg.to_s
      response = HTTParty.get(request)
      SmsLog.create(sms_from: sms_mask,sms_to: to, msg: msg,sms_by: "Admin",response: response.body)
    end
  end

end
