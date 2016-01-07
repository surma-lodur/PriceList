# encoding: UTF-8
module PriceList::Models
  autoload :Item,      File.join(File.dirname(__FILE__), 'models', 'item.rb')
  autoload :ItemPrice, File.join(File.dirname(__FILE__), 'models', 'item_price.rb')
  autoload :List,      File.join(File.dirname(__FILE__), 'models', 'list.rb')
end
