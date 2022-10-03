class ReportMailer < ApplicationMailer
    def new_report_email(pdf, subject, email, body)
        @subject = subject
        pdf.each_with_index do |pdf_s,index|
          attachments["#{pdf_s.last}.pdf"] = pdf_s.first
        end
        mail(to: email, subject: "#{subject} report from MunshiOnClick")
    end
end
