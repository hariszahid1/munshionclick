# Mailer
class ReportMailer < ApplicationMailer
  def new_report_email(pdf, subject, email, _body)
    @subject = subject
    pdf.each_with_index do |pdf_s, _index|
      attachments["#{pdf_s.last}.csv"] = pdf_s.first
    end
    mail(to: email, subject: "#{subject} report from MunshiOnClick")
  end

  def send_csv_pdf_email(csv, pdf, subject, email, body)
    @subject = subject
    if csv[0][0].present?
      csv.each do |csv_s|
        attachments["#{csv_s.last}.csv"] = csv_s.first
      end
    end
    if pdf[0][0].present?
      pdf.each do |pdf_s|
        attachments["#{pdf_s.last}.pdf"] = pdf_s.first
      end
    end
    mail(to: email, subject: subject, body: body)
  end

  def db_backup_file_email(email, file)
    attachments[File.basename(file[1])] = File.read(file[1], mode: 'rb')
    mail(to: email, subject: "Database Backup File for #{file[0]}", body: '')
  end
end
