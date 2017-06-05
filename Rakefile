# encoding: UTF-8

require_relative File.join('lib', 'price_list')
desc 'API Routes'
task :routes do
  PriceList::Api.routes.each do |api|
    method = api.route_method.ljust(10)
    path = api.route_path
    puts "     #{method} #{path}"
  end
end

desc 'Plot all price charts'
task :plot_price_charts do
  Item.available.each(&:plot_price_chart!) 
end

desc 'test parser ENV["URL"]' 
task :parse do 
  parser= PriceList::Parser.
    responsible_class_name(ENV['URL']).
    constantize.
    new(ENV['URL'])
  parser.parse
  pp parser
end

desc 'run plotter'
task :plot do
  PriceList::Models.initialize_db
  Item.available.each do |item|
    item.plot_price_chart!
  end
end

desc 'refetch'
task :refetch do
  PriceList::Models.initialize_db
  Supplier.refetch_prices
end

desc 'console'
task :console do
  require 'irb'
  require 'irb/completion'
  PriceList::Models.initialize_db
  ActiveRecord::Base.connection
  ARGV.clear
  IRB.start()
end
