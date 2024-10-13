require 'open-uri'
require 'net/https'

class PriceList::Parser
  attr_accessor :url, :price, :currency, :doc
  attr_reader :title, :stock_state

  Dir.glob(File.join(File.dirname(__FILE__), 'parser', '*.rb')).each do |file|
    autoload File.basename(file, '.rb').camelize.to_sym, file
  end

  def initialize(url)
    self.url = url
    parse
  end

  def parse
    raise PriceList::Exception.new('extend me')
  end

  def uri
    URI(url)
  end

  def html
    pp url
    URI(url).read(
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; rv:131.0) Gecko/20100101 Firefox/131.0'
    )
  end

  def doc
    Nokogiri::HTML(html)
  end

  def title=(string)
    @title = compact(string)
  end

  def stock_state=(string)
    @stock_state = compact(string)
  end

  protected

  def compact(string)
    string&.strip&.gsub(/\n|\t/, ' ')&.squeeze(' ')
  end

  class << self
    # Must be setted by subclass
    attr_accessor :responsible_base_url

    # will used to make loose caching of favicon urls
    attr_accessor :fetched_favicon_url

    def favicon_url
      checked_url = "#{responsible_base_url}/favicon.ico"
      self.fetched_favicon_url ||= url_exists?(checked_url) ? checked_url : nil
      self.fetched_favicon_url ||= url_exists?(fetch_favicon) ? fetch_favicon : nil
      self.fetched_favicon_url
    end

    def uri
      URI(responsible_base_url)
    end # .uri

    def responsible_regexp
      /#{Regexp.escape(uri.host).gsub('www', '.*')}/
    end # #responsible_regexp

    def responsible?(url)
      pp responsible_regexp unless PriceList.test?
      pp url unless PriceList.test?
      url =~ responsible_regexp
    end

    def responsible_class_name(url)
      puts "Check: #{url}" unless PriceList.test?
      constants.each do |constant|
        puts "Probe: #{constant}" unless PriceList.test?
        responsible = module_eval(constant.to_s).responsible?(url)
        puts "\t#{responsible}" unless PriceList.test?
        return "#{name}::#{constant}" if responsible
      end
      raise PriceList::Exception.new('no matching parser found for given url')
    end

    def fetch_favicon
      Nokogiri::HTML(
        uri.read
      ).css(
        'link[rel="apple-touch-icon"]'
      )&.first&.attr('href')
    rescue Exception => e
      puts e
      puts e.backtrace * "\n"
      nil
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
        true
      else
        false
      end
    end
  end #  class << self
end
