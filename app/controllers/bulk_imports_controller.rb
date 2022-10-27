# frozen_string_literal: true

# BulkImports Controller
class BulkImportsController < ApplicationController
  require 'csv'

  def bulk_import_data
    table_name = params[:bulk_import][:table_name]
    csv_text = File.read(params[:bulk_import][:file]).force_encoding('ISO-8859-1').encode('utf-8', replace: nil)
    csv = CSV.parse(csv_text, headers: true)
    import_mapping_fields = ImportMapping.find_by(table_name: table_name).included_fields
    if import_mapping_fields.eql? csv.headers
      csv.each do |row|
        data = row.to_h.reject { |k| k == 'id' }
        if row.values_at('id')[0].present?
          object = table_name.constantize.find_by(id: row.values_at('id'))
          object.update(data) if object.present?
        else
          table_name.constantize.find_or_create_by(data)
        end
        flash[:notice] = 'The record is updated successfully.'
      end
    else
      flash[:alert] = 'The template of given file is invalid.'
    end
    redirect_to request.referrer
  end
end
