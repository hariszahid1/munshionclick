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

  def db_backup_file_email(email_to, email_cc, email_bcc, company_type, link, date)
    @link = link
    @date = date
    mail(to: email_to, cc: email_cc, bcc: email_bcc, subject: "Database Backup File for #{company_type}") if email_to.present?
  end

  def send_report_files_email(email_to, email_cc, email_bcc, path_of_files, company_name, typeingly, type)
    return unless path_of_files.present?

    @typeingly = typeingly
    @company_name = company_name
    path_of_files.each do |p|
      file_name = p.split('/').last if p.present?
      attachments[file_name] = File.read(p)
    end
    mail(to: email_to, cc: email_cc, bcc: email_bcc, subject: "#{typeingly} #{type} Files") if email_to.present?
  end

  def follow_ups_notification(email_to, email_cc, email_bcc, follow_ups)
    @follow_ups = follow_ups
    return unless @follow_ups.present?
    mail(to: email_to, cc: email_cc, bcc: email_bcc, subject: "Alert for today Follow Ups") if email_to.present?
  end
end
