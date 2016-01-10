# encoding: UTF-8
class PriceList::Views
    def render
      File.open(File.join(PriceList::Root, 'public', 'index.html'), 'w') do |file|
        file.write(ERB.new(read_file('index.html.erb')).result(binding))
      end
    end

    def render_partial(name, options = {})
      proc_var = Class.new(PriceList::Views) do
        (options[:locals] || []).each do |key, value|
          define_method(key) do
            return value
          end
        end

        def get_binding
          binding
        end
      end

      ERB.new(read_file("#{name}.html.erb")).result(proc_var.new.get_binding)
    end

    def read_file(*args)
      File.open(base_path(args)).read
    end

    def base_path(*args)
      File.join(* ([File.dirname(__FILE__), 'views'] + args))
    end
end
