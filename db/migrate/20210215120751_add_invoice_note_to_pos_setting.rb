class AddInvoiceNoteToPosSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :pos_settings, :invoice_note, :text
  end
end
