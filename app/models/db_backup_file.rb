class DbBackupFile < ApplicationRecord
  has_one_attached :back_up_file, service: :db_files_bucket
end
