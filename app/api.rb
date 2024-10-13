class PriceList::Api < Grape::API
  autoload :Items,      File.join(File.dirname(__FILE__), 'api', 'items.rb')
  autoload :Admin,      File.join(File.dirname(__FILE__), 'api', 'admin.rb')
  mount PriceList::Api::Items
  mount PriceList::Api::Admin
  add_swagger_documentation
end
