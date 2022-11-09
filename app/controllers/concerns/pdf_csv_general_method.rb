# frozen_string_literal: true

# CSV Methods
module PdfCsvGeneralMethod
  extend ActiveSupport::Concern
  require 'tempfile'
  require 'csv'

  def generate_pdf(data, pdf_title, pdf_layout, page_size, html_type)
    @pos_setting = PosSetting.first
    request.format = 'pdf'
    @pdf_path = respond_to do |format|
      format.html
      format.pdf do
        render pdf: pdf_title,
               locals: { data: data },
               layout: pdf_layout,
               page_size: page_size,
               orientation: 'Portrait',
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
               show_as_html: html_type
      end
    end
  end

  def generate_csv(data, column_names, name)
		file = CSV.generate do |csv|
			csv.add_row column_names
			data.each do |item|
				csv.add_row item
			end
		end
    send_data file, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=#{name}.csv"
  end

  def export_data(table_name)
    @data = table_name.constantize.all
    import_mapping = ImportMapping.find_by(table_name: table_name)
    headers = import_mapping&.included_fields
    file = CSV.generate(headers: true) do |csv|
      csv << headers
      @data.each do |d|
        csv << d.as_json.values_at(*headers)
      end
    end
    send_data file, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=#{table_name}.csv"
  end

end
