source 'https://rubygems.org'

gem 'grape'
gem 'grape-swagger'
gem 'grape-entity'
gem 'haml'
gem 'nokogiri'#, '>= 1.6.7.rc'
gem 'clockwork'

gem 'rack'
gem 'rake'
gem 'puma'
gem 'sqlite3'
gem 'activerecord', '~> 5.1.1'
gem 'transitions', require: ['transitions', 'active_model/transitions']

group :development, :test do
  gem 'rspec'
  gem 'database_cleaner'
  gem 'guard-rspec'
  gem 'faker'
  gem 'rack-test'
  gem 'factory_girl'
  if Gem.win_platform?
    gem 'win32console'
    gem 'wdm'
  end
end
