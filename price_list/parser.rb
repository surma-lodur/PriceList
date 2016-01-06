# encoding: UTF-8
class PriceList::Parser

  attr_accessor :url, :title, :price, :currency, :stock_state

  Dir.glob(  File.join(File.dirname(__FILE__), 'parser', '*.rb')).each do |file|
    autoload File.basename(file,'.rb').camelize.to_sym, file
  end

  def initialize(url)
    self.url = url
    self.parse
  end

  def parse
    raise Exception.new('extend me')
  end

  def self.responsible?(url)
    raise Exception.new('extend me')
  end

  def self.responsible_class_name(url)
    self.constants.each do |constant|
      if self.module_eval(constant.to_s).responsible?(url)
        return "#{self.name}::#{constant.to_s}"
      end
    end
    raise Exception.new('no matching parser found')
  end
end
