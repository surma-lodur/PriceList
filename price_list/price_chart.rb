# encoding: UTF-8

module PriceList::PriceChart
  class << self
    def plot_item(item)
      store_plot_data(item)
      File.open(plot_conf_path(item), 'w') do |file|
        file.write(gnuplot_params(item))
      end
      `cat #{plot_conf_path(item)} | gnuplot`
    end

    def chart_path(item)
      base_path("#{item.id}.png")
    end

    protected

    def store_plot_data(item)
      File.open(plot_dat_path(item), 'w') do |file|
        item.item_prices.order('created_at DESC').each do |price_change|
          file.write(price_change.created_at.strftime('%Y-%m-%d-%H:%M:%S'))
          file.write(' ')
          file.write(price_change.price.to_s)
          file.write("\n")
        end
      end
    end

    def gnuplot_params(item)
      "set terminal png enhanced transparent  size 425,300  font \"Verdana,8\"
      set xdata time
      set timefmt \"%Y-%m-%d-%H:%M:%S\"
      set output \"#{chart_path(item)}\"

      # color definitions
      set border linewidth 1.5
      set style line 1 lc rgb '#0060ad' pt 7 ps 1.5 lt 1 lw 2 # --- blue
      set style line 2 lc rgb '#949599' lt 1 lw 2 # --- grey

      unset key
      unset title

      # Axes
      set style line 11 lc rgb '#808080' lt 1
      set border 3 back ls 11
      set tics nomirror out scale 0.75
      # Grid
      set style line 12 lc rgb'#808080' lt 0 lw 1
      set grid back ls 12

      plot \"#{plot_dat_path(item)}\" u 1:2 index 0 notitle w fsteps ls 2,\\
            ''                        u 1:2 index 0 notitle w points ls 1,
      " # steps candlesticks
    end

    def plot_conf_path(item)
      base_path("#{item.id}.conf")
    end

    def plot_dat_path(item)
      base_path("#{item.id}.dat")
    end

    def base_path(*args)
      File.join(* ([PriceList::Root, 'public', 'tmp'] + args))
    end
 end
end
