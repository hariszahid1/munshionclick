class EmailMultiFilesJob < ActiveJob::Base
  queue_as :default

  def perform(data, path, reciever, email_choice, subject, body, current_user, file_name)
    ActiveRecord::Base.establish_connection "#{Rails.env}_#{current_user.company_type}".to_sym
    if (email_choice.eql? 'CSV') || (email_choice.eql? 'Both')
      headers = data&.first&.keys
      @csv_file = CSV.generate(headers: true) do |csv|
        csv << headers
        data.each do |d|
          csv << d.as_json.values_at(*headers)
        end
      end
    end
    if (email_choice.eql? 'PDF') || (email_choice.eql? 'Both')
      @pos_setting = PosSetting.first
      @pdf_path = WickedPdf.new
                           .pdf_from_string(
                             ApplicationController.new.render_to_string(
                               template: path,
                               locals: { current_user: current_user, data: data },
                               margin: {
                                 margin_top: @pos_setting&.pdf_margin_top.to_f,
                                 margin_right: @pos_setting&.pdf_margin_right.to_f,
                                 margin_bottom: @pos_setting&.pdf_margin_bottom.to_f,
                                 margin_left: @pos_setting&.pdf_margin_left.to_f
                               },
                               layout: 'pdf.html',
                               footer: {
                                 right: '[page] of [topage]'
                               }
                             )
                           )
    end
    email = reciever.present? ? reciever : current_user.email
    csv = [[@csv_file, file_name]]
    pdf = [[@pdf_path, file_name]]

    ReportMailer.send_csv_pdf_email(csv, pdf, subject, email, body).deliver
  end
end
