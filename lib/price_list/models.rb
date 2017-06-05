# encoding: UTF-8
require 'active_record'
require 'sqlite3'

module PriceList::Models
  Dir.glob(File.join(PriceList::Root, 'app', 'models', '*.rb')) do |model|
    require model
  end

  def self.initialize_db
    db_name = 'development'
    if PriceList.test?
      db_name = 'test'
      puts 'Run in Test mode'
    else
      ActiveRecord::Base.logger = Logger.new(STDERR)
    end

    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: File.join(PriceList::Root, 'db', "#{db_name}.db")
    )
    ActiveRecord::Migrator.migrate(File.join(PriceList::Root, 'db','migrations'))
  end
end
