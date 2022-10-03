namespace :db do
  desc 'Drop, create, migrate then seed the development database'
  task reseed: ['db:drop', 'db:create', 'db:migrate', 'db:seed'] do
    puts 'Reseeding completed.'
  end

  desc "Run db migrations for additional database"
  task migrate: :environment do
    # Invoking rake db:migrate executes against the usual/default db
    # first, then this gets executed.
    all_db_configs   = Rails.configuration.database_configuration.select{|dbs| dbs.include?(Rails.env + '_')}
    all_db_configs.each do |db_block, db_config|
      company_name = db_block.split(Rails.env + '_')[1]
      puts company_name+' DB migration'
      ActiveRecord::Base.establish_connection "#{Rails.env}_#{company_name}".to_sym
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
end