# encoding: UTF-8
require 'rubygems'
require 'bundler/setup'
require 'pp'
require 'active_record'
Bundler.require

class PriceList
  autoload :Api,      File.join(File.dirname(__FILE__), 'price_list', 'api')
  autoload :Models,   File.join(File.dirname(__FILE__), 'price_list', 'models')
  autoload :Entities, File.join(File.dirname(__FILE__), 'price_list', 'entities')
  autoload :Parser,   File.join(File.dirname(__FILE__), 'price_list', 'parser')

  ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: "db/#{ENV['RAILS_ENV'] == 'test' ? 'test' : 'development'}.db"
  )

  unless ENV['RAILS_ENV'] == 'test'
    ActiveRecord::Base.logger = Logger.new(STDERR)
  end
  ActiveRecord::Base.connection.active?

  require File.join(File.dirname(__FILE__),  'db/migrations/0001_start_schema.rb')
  require File.join(File.dirname(__FILE__),  'db/seeds.rb')

  def initialize
    @filenames = ['', '.html', 'index.html', '/index.html']
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
        return response if response[0] != 404
      end
      # api
      return_value = Api.call(env)
      ActiveRecord::Base.clear_active_connections! # fixes the connection leak
      return return_value
    end
  end
end
