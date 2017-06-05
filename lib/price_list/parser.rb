# encoding: UTF-8

require 'open-uri'
require 'net/https'

class PriceList::Parser
  attr_accessor :url, :title, :price, :currency, :stock_state, :doc

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
    # Must be setted by subclass
    attr_accessor :responsible_base_url

    # will used to make loose caching of favicon urls
    attr_accessor :fetched_favicon_url

    def favicon_url
      checked_url = "#{responsible_base_url}/favicon.ico"
      self.fetched_favicon_url ||= self.url_exists?(checked_url) ? checked_url : nil
      self.fetched_favicon_url
    end

    def uri
      URI(self.responsible_base_url)
    end # .uri

    def responsible_regexp
       %r{#{Regexp.escape(self.uri.host).gsub('www','.*')}}
    end # #responsible_regexp

    def responsible?(url)
      pp self.responsible_regexp unless PriceList.test?
      pp url unless PriceList.test?
      url =~ self.responsible_regexp
    end

    def responsible_class_name(url)
      puts "Check: #{url}" unless PriceList.test?
      constants.each do |constant|
        puts "Probe: #{constant}" unless PriceList.test?
        responsible = module_eval(constant.to_s).responsible?(url)
        puts "\t#{responsible}"   unless PriceList.test?
        return "#{name}::#{constant}" if responsible
      end
      fail PriceList::Exception.new('no matching parser found for given url')
    end

    def url_exists?(_url)
      uri = URI(_url)
      req = Net::HTTP::Head.new(uri)

      http = Net::HTTP.new(uri.hostname, uri.port)
      if uri.scheme =~ /https/
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      res = http.request(req)

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        return true
      else
        return false
      end
    end
  end #  class << self
end
