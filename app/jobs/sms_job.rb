class SmsJob < ActiveJob::Base
 queue_as :default
  def perform(sms_user,sms_pass,sms_mask_erb,to,msg)
    request='http://my.ezeee.pk/sendsms_url.html?Username='+sms_user+'&Password='+sms_pass+'&From='+sms_mask_erb+'&To='+to+'&Message='+msg.to_s+'&type=ur'
    response = HTTParty.get(request)
  end
end
