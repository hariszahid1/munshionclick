# frozen_string_literal: true

# BulkImports Controller
class BulkImportsController < ApplicationController
  require 'csv'

  def bulk_import_data
    table_name = params[:bulk_import][:table_name]
    csv_text = File.read(params[:bulk_import][:file]).force_encoding('ISO-8859-1').encode('utf-8', replace: nil)
    csv = CSV.parse(csv_text, headers: true)
    return bulk_import_for_crm if table_name == 'CRM'

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

  def bulk_delete_data
    data = params[:table_name].constantize.where(id: params[:ids])
    if data.present?
      data.destroy_all
      render json: {message: "Record was successfully deleted."}
    end
  end

  def bulk_import_for_crm
    csv_text = File.read(params[:bulk_import][:file]).force_encoding('ISO-8859-1').encode('utf-8', replace: nil)
    csv = CSV.parse(csv_text, headers: true)
    headers = %w[occupation name credit_status gst ntn]
    crm_headers = %w[id number name agent_id plot_size short_details project_name client_type client_status category deal_status source]
    if crm_headers.eql? csv.headers
      csv.each do |row|
        data = row.to_h.reject { |k| k == 'id' }
        cms_data = data.slice('project_name', 'client_type', 'client_status', 'category', 'deal_status', 'source')
        data = data.excluding('project_name', 'client_type', 'client_status', 'category', 'deal_status', 'source')
        data1 = headers.zip(data.values).to_h
        code = "AGC-"+"%.4i" % (SysUser.maximum(:id).present? ? SysUser.maximum(:id).next : 1)
        data1 = data1.merge('user_type_id' => UserType.first.id,
                            'cms_data' => cms_data, 'for_crms' => true, 'code' => code)
        if row.values_at('id')[0].present?
          object = SysUser.find_by(id: row.values_at('id'))
          object.update(data1) if object.present?
        else
          SysUser.find_or_create_by(data1)
        end
        flash[:notice] = 'The record is updated successfully.'
      end
    else
      flash[:alert] = 'The template of given file is invalid.'
    end
    flash[:alert] = 'The template of given file is invalid.'
    redirect_to request.referrer
  end
end
