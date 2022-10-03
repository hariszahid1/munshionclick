class BdBackupsController < ApplicationController
  def index
    directory = File.join(Rails.root).split('/releases/')[0] + '/shared/db_backup'
    @db_backup_files = Dir.glob("#{directory}/**/#{RequestStore.store[:company_type]}/*").sort_by{ |f| File.ctime(f) }.reverse

    # directory = File.join(Rails.root).split('/releases/')[0] + '/shared/db_backup'+'/20211125'
    # puts "-----------------------------------------------------------------------------------"
    # all_db_configs   = Rails.configuration.database_configuration.select{|dbs| dbs.include?(Rails.env + '_')}
    # all_db_configs.each do |db_block, db_config|
      # company_name = db_block.split(Rails.env + '_')[1]
      # # puts company_name+' DB migration'
      # final_folder = File.join(directory+'/'+company_name)
      # final_file = ''
      # final_file_path = ''
      # Dir.children(final_folder).each do |file|
      #   final_file_path = final_folder+'/'+file
      #   final_file = file
      # end
      # @pos_setting=PosSetting.first
      # puts final_file
      # puts "================"
      # puts current_user.superAdmin.id
      # current_user.superAdmin.backup_files.attach(io: File.open(final_file_path), filename: final_file.to_s)
      # subject = "Today Backup of System #{Date.today}"
      # email = "abaid.awan@ucp.edu.pk"
      # require 'set'
      # # infile = open(final_file)
      # # gz = Zlib::GzipReader.new(infile)
      # gz = File.open(final_file){|f| f.read}
      # pdf=[[gz,'DbFile']]
      # ReportMailer.new_report_email_gz(pdf,subject,email,"").deliver
    # end
  end

  def import
    backup_file = params[:backup_file]
    begin
      db = YAML::load(File.open(File.join(Rails.root, 'config', 'database.yml')))[Rails.env + '_' + RequestStore.store[:company_type]]
      directory = File.join(Rails.root).split('/releases/')[0] + '/shared/db_backup'
      wildcard  = File.join(directory, backup_file)
        file = `ls -t #{wildcard} | head -1`.chomp
      Rails.logger.info "-----file: #{file}"
      Rails.logger.info 'please wait........., this may take a minute or two...'
      system "bin/rails db:environment:set RAILS_ENV=#{Rails.env + '_' + RequestStore.store[:company_type]}"
      Rails.logger.info system "RAILS_ENV=#{Rails.env + '_' + RequestStore.store[:company_type]} rake db:drop"
      Rails.logger.info system "RAILS_ENV=#{Rails.env + '_' + RequestStore.store[:company_type]} rake db:create"

      if file =~ /\.gz(ip)?$/
        Rails.logger.info system "gunzip < #{file} | mysql -h 127.0.0.1 -u#{db['username']} -p#{db['password']} #{db['database']}"
      else
        Rails.logger.info system "mysql -h 127.0.0.1 -u#{db['username']} -p#{db['password']} #{db['database']} < #{file} "
      end
      Rails.logger.info system "RAILS_ENV=#{Rails.env + '_' + RequestStore.store[:company_type]} rake db:migrate"

      redirect_to bd_backups_path, notice: 'Database Imported!'
    rescue => e
      Rails.logger.info "-----file: #{e.inspect}"
      redirect_to bd_backups_path, notice: "Error: #{e.inspect}"
    end
  end

  def export
    company_name = RequestStore.store[:company_type]
    db_config = YAML::load(File.open(File.join(Rails.root, 'config', 'database.yml')))[Rails.env + '_' + company_name]
    backup_folder = File.join(Rails.root).split('/releases/')[0] + '/shared/db_backup'
    FileUtils.mkdir(backup_folder) unless File.directory? backup_folder
    backup_date_foler = File.join(backup_folder, Date.today.to_s.gsub('-', ''))
    FileUtils.mkdir(backup_date_foler) unless File.directory? backup_date_foler
    backup_date_db_folder = File.join(backup_date_foler, company_name)
    FileUtils.mkdir(backup_date_db_folder) unless File.directory? backup_date_db_folder

    datestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    backup_file = File.join(backup_date_db_folder, "#{company_name}_#{datestamp}_dump.sql.gz")
    Rails.logger.info "backup_file------: #{backup_file}"
    Rails.logger.info system "mysqldump --opt --skip-add-locks -h 127.0.0.1 -u #{db_config['username']} #{db_config['database']} | gzip > #{backup_file}"
    redirect_to bd_backups_path, notice: 'Database Exported!'
  end
end
