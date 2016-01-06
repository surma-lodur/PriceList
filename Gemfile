source 'https://rubygems.org'

gem 'grape'
gem 'grape-swagger'
gem 'grape-entity'
gem 'nokogiri', '>= 1.6.7.rc'
gem 'clockwork'

gem 'rack'
gem 'rake'
gem 'thin'
gem 'sqlite3'
gem 'activerecord'
gem 'transitions', require: ['transitions', 'active_model/transitions']

group :development, :test do
  gem 'rspec'
  gem 'database_cleaner'
  gem 'guard-rspec'
  gem 'rack-test'
  if Gem.win_platform?
    gem 'win32console' 
    gem 'wdm'
  end
end
