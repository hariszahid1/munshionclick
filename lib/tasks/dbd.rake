namespace :dbd do
  desc 'Backup database by mysqldump'
  task :backup => :environment do
    all_db_configs   = Rails.configuration.database_configuration.select{|dbs| dbs.include?(Rails.env + '_')}
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

  desc "restore most recent mysqldump (from db/backup/*.sql.*) into the current environment's database."
  task :restore => :environment do |name|
    unless Rails.env=='development'
      puts "Are you sure you want to import into #{Rails.env}?! [y/N]"
      return unless STDIN.gets =~ /^y/i
    end
    db = YAML::load( File.open( File.join(Rails.root, 'config', 'database.yml') ) )[ Rails.env ]
    directory = File.join( Rails.root, 'db', 'backup')
    wildcard  = File.join( directory, ENV['FILE'] || "#{ENV['FROM']}*.sql.*" )
    puts file = `ls -t #{wildcard} | head -1`.chomp  # default to file, or most recent ENV['FROM'] or just plain most recent
    puts "please wait, this may take a minute or two..."
    if file =~ /\.gz(ip)?$/
      exec "gunzip < #{file} | mysql  -u #{db['username']} -p#{db['password']} #{db['database']}"
    else
      exec "mysqlimport -u #{db['username']} -p#{db['password']} #{db['database']} #{file}"
    end
  end
end