namespace :db do
  desc 'Drop, create, migrate then seed the development database'
  task reseed: ['db:drop', 'db:create', 'db:migrate', 'db:seed'] do
    puts 'Reseeding completed.'
  end

  desc "Run db migrations for additional database"
  task migrate: :environment do
    # Invoking rake db:migrate executes against the usual/default db
    # first, then this gets executed.
    all_db_configs   = Rails.configuration.database_configuration.select{|dbs| dbs.include?(Rails.env)}
    all_db_configs.each do |db_block, db_config|
      company_name = db_block.split(Rails.env)[1]
      puts company_name.to_s+' DB migration'
			if company_name.blank?
	      ActiveRecord::Base.establish_connection "#{Rails.env}".to_sym
			else
				ActiveRecord::Base.establish_connection "#{Rails.env}#{company_name}".to_sym
			end
      migrations = if ActiveRecord.version.version >= '5.2'
        ActiveRecord::Migration.new.migration_context.migrations
      else
        ActiveRecord::Migrator.migrations('db/migrate')
      end
      ActiveRecord::MigrationContext.new(Rails.root.join('db', 'migrate'), ActiveRecord::SchemaMigration).migrate
      # ActiveRecord::Migrator.new(:up, migrations, nil).migrate
    end
  end

  desc 'Backup database by mysqldump'
  task :backup, [:database]=> :environment do |t, args|
    if args.database.present?
        all_db_configs = Rails.configuration.database_configuration.select{|dbs| dbs.include?(Rails.env + '_')}
        company_name = args.database
        db_config=all_db_configs[Rails.env+'_'+company_name]
        datestamp = Time.now.strftime("%Y%m%d_%H%M%S")
        backup_folder = File.join(Rails.root).split('/releases/')[0] + '/shared/db_backup'
        FileUtils.mkdir(backup_folder) unless File.directory? backup_folder
        backup_date_foler = File.join(backup_folder, Date.today.to_s.gsub('-',''))
        FileUtils.mkdir(backup_date_foler) unless File.directory? backup_date_foler
        backup_date_db_folder = File.join(backup_date_foler, company_name)
        FileUtils.mkdir(backup_date_db_folder) unless File.directory? backup_date_db_folder
        backup_file = File.join(backup_date_db_folder, "#{company_name}_#{datestamp}_dump.sql.gz")
        sh "mysqldump --opt --skip-add-locks -h 127.0.0.1 -u #{db_config['username']} #{db_config['database']} | gzip > #{backup_file}"
    else
      all_db_configs = Rails.configuration.database_configuration.select{|dbs| dbs.include?(Rails.env + '_')}
      all_db_configs.each do |db_block, db_config|
        company_name = db_block.split(Rails.env + '_')[1]
        datestamp = Time.now.strftime("%Y%m%d_%H%M%S")
        backup_folder = File.join(Rails.root).split('/releases/')[0] + '/shared/db_backup'
        FileUtils.mkdir(backup_folder) unless File.directory? backup_folder
        backup_date_foler = File.join(backup_folder, Date.today.to_s.gsub('-',''))
        FileUtils.mkdir(backup_date_foler) unless File.directory? backup_date_foler
        backup_date_db_folder = File.join(backup_date_foler, company_name)
        FileUtils.mkdir(backup_date_db_folder) unless File.directory? backup_date_db_folder
        backup_file = File.join(backup_date_db_folder, "#{company_name}_#{datestamp}_dump.sql.gz")
        sh "mysqldump --opt --skip-add-locks -h 127.0.0.1 -u #{db_config['username']} #{db_config['database']} | gzip > #{backup_file}"
      end
    end
  end

  desc "Load testcron"
  task :stockcron => :environment do
    puts "Stock Dump at 12:00 PM Rake"
    all_db_configs   = Rails.configuration.database_configuration.select{|dbs| dbs.include?(Rails.env + '_')}
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym

      products=Product.pluck(:id,:stock,:cost,:sale)
      product_stock=Product.group(:id).sum(:stock)
      @date = DateTime.now
      sale=PurchaseSaleItem.where(created_at: @date.to_date.beginning_of_day..@date.to_date.end_of_day,transaction_type: "Sale").group(:product_id).sum(:quantity)
      purchase=PurchaseSaleItem.where(created_at: @date.to_date.beginning_of_day..@date.to_date.end_of_day,transaction_type: "Purchase").group(:product_id).sum(:quantity)
      nakasi=SalaryDetailProductQuantity.where(created_at: @date.to_date.beginning_of_day..@date.to_date.end_of_day).group(:product_id).sum(:quantity)
      if sale.present? && (purchase.present? || nakasi.present?)
        products.each do |product|
          # total_stock=(product_stock[product.first].to_f+purchase[product.first].to_f+nakasi[product.first].to_f)-sale[product.first].to_f
          total_stock=product_stock[product.first].to_f
          product_stock[product.first]=total_stock
          ProductStock.create(product_id: product.first, in_stock: purchase[product.first].to_f+nakasi[product.first].to_f, out_stock: sale[product.first].to_f,stock: total_stock, cost_price: product.third, sale_price: product.last, created_at: @date)
        end
      else
        products.each do |product|
          total_stock=product_stock[product.first].to_f
          ProductStock.create(product_id: product.first, in_stock: 0, out_stock: 0, stock: total_stock, cost_price: product.third, sale_price: product.last, created_at: @date)
        end
      end #if end
    end# databases end
  end #function End

  desc "Load filesend"
  task :filesend => :environment do
    all_db_configs = Rails.configuration.database_configuration.select{|dbs| dbs.include?(Rails.env + '_')}
    date_for_folder = Date.yesterday.to_s.gsub('-', '')
    file_path = []
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      path_to_file = Dir[Rails.root.join("../../shared/db_backup/#{date_for_folder}/#{db_block.split(Rails.env + '_')[1]}/*").to_s][0]
      file_path << [db_block.split(Rails.env + '_')[1], path_to_file]
      file = File.open(path_to_file)
      db_backup_data = DbBackupFile.create(company_type: db_block, folder_date: Date.yesterday)
      db_backup_data.back_up_file.attach(io: file, filename: path_to_file.split('/').last)
      file_serice_url = "https://munshionclick.com/db_backup_files/#{db_backup_data.id}"
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      email_to = PosSetting.last&.email_to&.split(',')
      email_cc = PosSetting.last&.email_cc&.split(',')
      email_bcc = PosSetting.last&.email_bcc&.split(',')
      ReportMailer.db_backup_file_email(email_to, email_cc, email_bcc, db_block, file_serice_url, Date.yesterday).deliver
    end
  end

  desc "Load report_files_save"
  task report_files_save_daily: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      reports = %w[chart-of-account sysuser-ledger-book staff-ledger-book sale purchase payment expense investment payable recieveable]
      reports.each do |a|
        ApplicationRecord.chart_of_account_pdf(database, a, 'daily', nil)
      end
    end
  end

  desc "Load report_files_save"
  task logs_files_save_daily: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      reports = %w[sysuser-ledger-book staff-ledger-book sale purchase payment expense investment]
      reports.each do |a|
        ApplicationRecord.chart_of_account_pdf(database, a, 'daily', 'logs')
      end
    end
  end

  desc 'Load send_report_files'
  task send_report_files_daily: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      email_to = PosSetting.last&.email_to&.split(',')
      email_cc = PosSetting.last&.email_cc&.split(',')
      email_bcc = PosSetting.last&.email_bcc&.split(',')
      date_for_folder = Date.yesterday.to_s.gsub('-', '')
      path_to_files = Dir[Rails.root.join("../../shared/reports/daily/#{date_for_folder}/#{database}/*").to_s]
      ReportMailer.send_report_files_email(email_to, email_cc, email_bcc, path_to_files, database, 'Daily', 'Report').deliver
      remove_dir(Rails.root.join("../../shared/reports/daily/#{date_for_folder}/#{database}"))
    end
  end

  desc 'Load send_report_files'
  task send_logs_files_daily: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      email_to = PosSetting.last&.email_to&.split(',')
      email_cc = PosSetting.last&.email_cc&.split(',')
      email_bcc = PosSetting.last&.email_bcc&.split(',')
      date_for_folder = Date.yesterday.to_s.gsub('-', '')
      path_to_files = Dir[Rails.root.join("../../shared/version_reports/daily/#{date_for_folder}/#{database}/*").to_s]
      ReportMailer.send_report_files_email(email_to, email_cc, email_bcc, path_to_files, database, 'Daily', 'Log').deliver
      remove_dir(Rails.root.join("../../shared/version_reports/daily/#{date_for_folder}/#{database}"))
    end
  end

  desc "Load report_files_save"
  task report_files_save_weekly: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      reports = %w[chart-of-account sysuser-ledger-book staff-ledger-book sale purchase payment expense investment payable recieveable]
      reports.each do |a|
        ApplicationRecord.chart_of_account_pdf(database, a, 'weekly', nil)
      end
    end
  end

  desc "Load report_files_save"
  task logs_files_save_weekly: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      reports = %w[sysuser-ledger-book staff-ledger-book sale purchase payment expense investment]
      reports.each do |a|
        ApplicationRecord.chart_of_account_pdf(database, a, 'weekly', 'logs')
      end
    end
  end

  desc 'Load send_report_files'
  task send_report_files_weekly: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      email_to = PosSetting.last&.email_to&.split(',')
      email_cc = PosSetting.last&.email_cc&.split(',')
      email_bcc = PosSetting.last&.email_bcc&.split(',')
      date_for_folder = Date.yesterday.to_s.gsub('-', '')
      path_to_files = Dir[Rails.root.join("../../shared/reports/weekly/#{date_for_folder}/#{database}/*").to_s]
      ReportMailer.send_report_files_email(email_to, email_cc, email_bcc, path_to_files, database, 'Weekly', 'Report').deliver
      remove_dir(Rails.root.join("../../shared/reports/weekly/#{date_for_folder}/#{database}"))
    end
  end

  desc 'Load send_report_files'
  task send_logs_files_weekly: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      email_to = PosSetting.last&.email_to&.split(',')
      email_cc = PosSetting.last&.email_cc&.split(',')
      email_bcc = PosSetting.last&.email_bcc&.split(',')
      date_for_folder = Date.yesterday.to_s.gsub('-', '')
      path_to_files = Dir[Rails.root.join("../../shared/version_reports/weekly/#{date_for_folder}/#{database}/*").to_s]
      ReportMailer.send_report_files_email(email_to, email_cc, email_bcc, path_to_files, database, 'Weekly', 'Log').deliver
      remove_dir(Rails.root.join("../../shared/version_reports/weekly/#{date_for_folder}/#{database}"))
    end
  end

  desc "Load report_files_save"
  task report_files_save_monthly: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      reports = %w[chart-of-account sysuser-ledger-book staff-ledger-book sale purchase payment expense investment payable recieveable]
      reports.each do |a|
        ApplicationRecord.chart_of_account_pdf(database, a, 'monthly', nil)
      end
    end
  end

  desc "Load report_files_save"
  task logs_files_save_monthly: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      reports = %w[sysuser-ledger-book staff-ledger-book sale purchase payment expense investment]
      reports.each do |a|
        ApplicationRecord.chart_of_account_pdf(database, a, 'monthly', 'logs')
      end
    end
  end

  desc 'Load send_report_files'
  task send_report_files_monthly: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      email_to = PosSetting.last&.email_to&.split(',')
      email_cc = PosSetting.last&.email_cc&.split(',')
      email_bcc = PosSetting.last&.email_bcc&.split(',')
      date_for_folder = Date.yesterday.to_s.gsub('-', '')
      path_to_files = Dir[Rails.root.join("../../shared/reports/monthly/#{date_for_folder}/#{database}/*").to_s]
      ReportMailer.send_report_files_email(email_to, email_cc, email_bcc, path_to_files, database, 'Monthly', 'Report').deliver
      remove_dir(Rails.root.join("../../shared/reports/monthly/#{date_for_folder}/#{database}"))
    end
  end

  desc 'Load send_report_files'
  task send_logs_files_monthly: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      email_to = PosSetting.last&.email_to&.split(',')
      email_cc = PosSetting.last&.email_cc&.split(',')
      email_bcc = PosSetting.last&.email_bcc&.split(',')
      date_for_folder = Date.yesterday.to_s.gsub('-', '')
      path_to_files = Dir[Rails.root.join("../../shared/version_reports/monthly/#{date_for_folder}/#{database}/*").to_s]
      ReportMailer.send_report_files_email(email_to, email_cc, email_bcc, path_to_files, database, 'Monthly', 'Log').deliver
      remove_dir(Rails.root.join("../../shared/version_reports/monthly/#{date_for_folder}/#{database}"))

    end
  end

  desc 'Load follow_ups_notify'
  task follow_ups_notify: :environment do
    all_db_configs = Rails.configuration.database_configuration.select{ |dbs| dbs.include?(Rails.env + '_') }
    all_db_configs.each do |db_block, db_config|
      database = db_block.split(Rails.env + '_')[1]
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{database}".to_sym
      email_to = PosSetting.last&.email_to&.split(',')
      email_cc = PosSetting.last&.email_cc&.split(',')
      email_bcc = PosSetting.last&.email_bcc&.split(',')
      follow_ups = FollowUp.where(date: Time.current.all_day)
      ReportMailer.follow_ups_notification(email_to, email_cc, email_bcc, follow_ups).deliver
    end
  end

end
