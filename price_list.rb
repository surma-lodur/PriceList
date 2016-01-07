# encoding: UTF-8
require 'rubygems'
require 'bundler/setup'
require 'pp'
require 'active_record'
Bundler.require

class PriceList
  autoload :Api,       File.join(File.dirname(__FILE__), 'price_list', 'api')
  autoload :Models,    File.join(File.dirname(__FILE__), 'price_list', 'models')
  autoload :Entities,  File.join(File.dirname(__FILE__), 'price_list', 'entities')
  autoload :Parser,    File.join(File.dirname(__FILE__), 'price_list', 'parser')
  autoload :Exception, File.join(File.dirname(__FILE__), 'price_list', 'exception')

  db_name  = 'development'
  if ENV['RAILS_ENV'] == 'test'
    db_name = 'test'
    puts 'Run in Test mode'
  else
    ActiveRecord::Base.logger = Logger.new(STDERR)
  end

  ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: "db/#{db_name}.db"
  )
  ActiveRecord::Base.connection.active?
  ActiveRecord::Migrator.migrate('db/migrations/')

  AuthConfig = YAML.load_file(File.join(File.dirname(__FILE__), 'config/auth.yml'))

  require File.join(File.dirname(__FILE__),  'db/seeds.rb')

  def initialize
    @filenames = ['', '.html', 'index.html', '/index.html', 'favicon.ico']
    @rack_static = ::Rack::Static.new(
      lambda { [404, {}, []] }, {
        root: File.expand_path(File.join('..', 'public'), __FILE__),
        urls: %w(/)
      })
  end

  def call(env)
    if env['HTTP_USER_AGENT'] and env['HTTP_USER_AGENT'] =~ /facebook/
      puts '!!Catched Facebook'
      return env
    else
      ActiveRecord::Base.verify_active_connections! if ActiveRecord::Base.respond_to?(:verify_active_connections!)
      request_path = env['PATH_INFO']
      # static files
      @filenames.each do |path|
        response = @rack_static.call(env.merge({ 'PATH_INFO' => request_path + path }))
        return response unless [404, 405].include?(response[0])
      end
      # api
      return_value = Api.call(env)
      ActiveRecord::Base.clear_active_connections! # fixes the connection leak
      return return_value
    end
  end
end
