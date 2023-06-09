class CreateUserPermission < ActiveRecord::Migration[6.1]
  def change
    create_table :user_permissions do |t|
			t.string :module
			t.boolean :can_create, default: :false
			t.boolean :can_read, default: :false
			t.boolean :can_update, default: :false
			t.boolean :can_delete, default: :false
			t.boolean :can_accessed, default: true
			t.boolean :is_hidden ,deafult: true
			t.boolean :can_download_pdf ,deafult: true
			t.boolean :can_download_csv ,deafult: true
			t.boolean :can_send_email ,deafult: true
			t.boolean :can_import_export ,deafult: true
			t.references :user
      t.timestamps
    end
  end
end
