# encoding: UTF-8
require 'erb'
#require 'haml'
class PriceList::Views
  def render
    File.open(File.join(PriceList::Root, 'public', 'index.html'), 'w') do |file|
      file.write(ERB.new(read_file('index.html.erb')).result(binding))
      #file.write(Haml::Engine.new(read_file('index.haml')).render(binding))
    end
  end

  def render_partial(name, options = {})
puts "render partial #{name}"
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
    #Haml::Engine.new(read_file("#{name}.haml")).render(proc_var.new.get_binding)
  end

  def read_file(*args)
    File.open(base_path(args)).read
  end

  def base_path(*args)
    File.join(* ([File.join(PriceList::Root, 'app'), 'views'] + args))
  end
end
