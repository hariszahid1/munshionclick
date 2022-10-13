class EmailJob < ActiveJob::Base
  queue_as :default
  include PdfCsvEmailMethod

  def perform(db_name, ids, name, path, email)
    ActiveRecord::Base.establish_connection "#{Rails.env}_#{db_name.company_type}".to_sym
    data = name.constantize.where(id: ids)
    # mail_pdf_csv(data, name, path, email)
    headers = data.column_names
    @csv_file = CSV.generate(headers: true) do |csv|
      csv << headers
      data.each do |d|
        csv << d.as_json.values_at(*headers)
      end
    end
    @pos_setting = PosSetting.first
    subject = "#{@pos_setting.display_name} - #{name} Detail"
    @pdf_path = WickedPdf.new.pdf_from_string(ApplicationController.new.render_to_string(template: "#{path}/index.pdf.erb",
                                                                                         locals: { current_user: db_name, cities: data },
                                                                                         margin: {
                                                                                                    margin_top: @pos_setting&.pdf_margin_top.to_f,
                                                                                                    margin_right: @pos_setting&.pdf_margin_right.to_f,
                                                                                                    margin_bottom: @pos_setting&.pdf_margin_bottom.to_f,
                                                                                                    margin_left: @pos_setting&.pdf_margin_left.to_f,
                                                                                          },
                                                                                          footer: {
                                                                                            right: '[page] of [topage]'
                                                                                          },
                                                                                          layout: 'pdf.html'))
    email = email.present? ? email : db_name.email
    csv = [[@csv_file, name]]
    pdf = [[@pdf_path, name]]
    ReportMailer.send_csv_pdf_email(csv, pdf, subject, email, '').deliver
  end
end
