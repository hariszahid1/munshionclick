class CreateSmsLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :sms_logs do |t|
      t.string :sms_from
      t.text :sms_to
      t.text :msg
      t.text :sms_by
      t.text :response

      t.timestamps
    end
  end
end
