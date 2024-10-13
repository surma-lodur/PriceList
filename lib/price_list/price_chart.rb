class PriceList::PriceChart
  autoload :Svg, File.join(File.dirname(__FILE__), 'price_chart', 'svg.rb')

  class << self
    def plot_item(item)
      PriceList::PriceChart::Svg.plot_item(item)
    end

    def chart_path(item)
      PriceList::PriceChart::Svg.chart_path(item)
    end

    protected

    def base_path(*args)
      File.join(* ([PriceList::Root, 'public', 'tmp'] + args))
    end
  end
end
