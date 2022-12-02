class DbBackupFilesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @q = DbBackupFile.ransack(params[:q])
    @db_backup_files = @q.result.page(params[:page])
  end

  def show
    @db_backup_file = DbBackupFile.find(params[:id])
  end
end
