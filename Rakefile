# encoding: UTF-8
require File.join('.', 'price_list')

desc 'API Routes'
task :routes do
  PriceList::Api.routes.each do |api|
    method = api.route_method.ljust(10)
    path = api.route_path
    puts "     #{method} #{path}"
  end
end