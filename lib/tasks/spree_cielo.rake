namespace :spree_cielo do
  desc "Copies all migrations (NOTE: This will be obsolete with Rails 3.1)"
  task :install do
    Rake::Task['spree_cielo:install:migrations'].invoke
    Rake::Task['spree_cielo:install:configs'].invoke
  end

  namespace :install do
    desc "Copies all migrations (NOTE: This will be obsolete with Rails 3.1)"
    task :migrations do
      source = File.join(File.dirname(__FILE__), '..', '..', 'db')
      destination = File.join(Rails.root, 'db')
      puts "INFO: Mirroring assets from #{source} to #{destination}"
      Spree::FileUtilz.mirror_files(source, destination)
    end
    
    desc "Copies all config files (NOTE: This will be obsolete with Rails 3.1)"
    task :configs do
      source = File.join(File.dirname(__FILE__), '..', '..', 'config_files')
      destination = File.join(Rails.root, 'config') 
      puts "INFO: Mirroring config files from #{source} to #{destination}"
      Spree::FileUtilz.mirror_files(source, destination)
    end
    
    # desc "Copies all assets (NOTE: This will be obsolete with Rails 3.1)"
    #     task :assets do
    #       source = File.join(File.dirname(__FILE__), '..', '..', 'public')
    #       destination = File.join(Rails.root, 'public')
    #       puts "INFO: Mirroring assets from #{source} to #{destination}"
    #       Spree::FileUtilz.mirror_files(source, destination)
    #     end
  end

end