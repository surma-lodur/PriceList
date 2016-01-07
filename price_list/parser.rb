# encoding: UTF-8

require 'open-uri'
require 'net/https'

class PriceList::Parser
  attr_accessor :url, :title, :price, :currency, :stock_state

  Dir.glob(File.join(File.dirname(__FILE__), 'parser', '*.rb')).each do |file|
    autoload File.basename(file, '.rb').camelize.to_sym, file
  end

  def initialize(url)
    self.url = url
    parse
  end

  def parse
    fail PriceList::Exception.new('extend me')
  end

  class << self
    def responsible?(url)
      fail PriceList::Exception.new('extend me')
    end

    def responsible_class_name(url)
      puts "Check: #{url}"
      constants.each do |constant|
        puts "Probe: #{constant}"
        responsible = module_eval(constant.to_s).responsible?(url)
        puts "\t#{responsible}"
        return "#{name}::#{constant}" if responsible
      end
      fail PriceList::Exception.new('no matching parser found for given url')
    end
  end #  class << self
end
