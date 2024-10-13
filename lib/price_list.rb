require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'pp'
Bundler.require

class PriceList
  AuthConfig = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'config/auth.yml'))
  Root = File.expand_path('..', File.dirname(__FILE__))

  require File.join(File.dirname(__FILE__), 'price_list', 'models')
  require File.join(File.dirname(__FILE__), 'price_list', 'views')

  require File.join(File.dirname(__FILE__), 'price_list', 'parser')
  require File.join(File.dirname(__FILE__), 'price_list', 'exception')
  require File.join(File.dirname(__FILE__), 'price_list', 'price_chart')

  require File.join(File.dirname(__FILE__), '..', 'app', 'entities')
  require File.join(File.dirname(__FILE__), '..', 'app', 'api')

  require_relative '../db/seeds' # File.join(File.dirname(__FILE__), 'db/seeds.rb')

  def initialize
    PriceList::Views.new.render
    PriceList::Models.initialize_db
    @filenames = ['', '.html', 'index.html', '/index.html', 'favicon.ico']
    @rack_static = ::Rack::Static.new(
      -> { [404, {}, []] }, {
        root: File.expand_path(File.join('../..', 'public'), __FILE__),
        urls: %w[/]
      }
    )
  end

  def call(env)
    if env['HTTP_USER_AGENT'] and env['HTTP_USER_AGENT'] =~ /facebook/
      puts '!!Catched Facebook'
      env
    else
      ActiveRecord::Base.verify_active_connections! if ActiveRecord::Base.respond_to?(:verify_active_connections!)
      request_path = env['PATH_INFO']
      # static files
      @filenames.each do |path|
        response = @rack_static.call(env.merge({ 'PATH_INFO' => request_path + path }))
        return response unless [404, 405].include?(response[0])
      end
      # api
      Api.call(env)

    end
  end

  class << self
    def test?
      ENV['RAILS_ENV'] == 'test'
    end # .test?
  end # class << self
end
