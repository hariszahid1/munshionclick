class CreateDbBackupFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :db_backup_files do |t|
      t.string :company_type
      t.string :folder_date

      t.timestamps
    end
  end
end
