class PriceList::PriceChart::Svg < PriceList::PriceChart
  class << self
    def plot_item(item)
      require 'svggraph'
      File.open(chart_path(item), 'w') do |file|
        file.write(
          plot_svg(item)
        )
      end
    end

    def chart_path(item)
      base_path("#{item.id}.svg")
    end

    protected

    def plot_svg(item)
      min_x_value = item.suppliers.joins(:item_prices).minimum(:created_at)
      min_y_value = item.suppliers.joins(:item_prices).minimum(:price)

      g = SVG::Graph::TimeSeries.new({
                                       width: 640,
                                       height: 300,
                                       graph_title: item.title,
                                       show_graph_title: true,
                                       no_css: true,
                                       key: true,
                                       scale_x_integers: true,
                                       scale_y_integers: true,
                                       show_data_values: false,
                                       show_x_guidelines: true,
                                       show_x_title: false,
                                       show_y_title: false,
                                       show_lines: false,
                                       y_title_text_direction: :bt,
                                       stagger_x_labels: false,
                                       min_x_value: min_x_value.to_time, # this must a Time object
                                       min_y_value:,
                                       timescale_divisions: '1 month',
                                       # set timefmt \"%Y-%m-%d-%H:%M:%S\"
                                       add_popups: true,
                                       x_label_format: '%m/%y',
                                       area_fill: false
                                     })
      generate_data(item).each do |klass, data|
        g.add_data(
          data:,
          title: klass
        )
      end
      g.burn_svg_only
    end

    def generate_data(item)
      FileUtils.mkdir_p(base_path)
      item.suppliers
          .joins(:item_prices)
          .pluck('suppliers.parser_class, item_prices.created_at, item_prices.price')
          .each_with_object({}) do |array, hash|
        hash[array[0]] ||= []
        hash[array[0]] += array[1..-1]
      end
    end
  end
end
