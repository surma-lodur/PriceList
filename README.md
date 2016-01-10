# PriceList
Simple App to watch on price changes from different sources.
For example Shop sites to get the cheapest price over a long time distance.

## Parser

The Parser section are empty, write your own and check if the source allow web robots.
Put them into the price_list/parser directory and they will autoloaded.

Pay attention to the ruby convention that the filename a simmilar to the included class/module name.

```ruby
# encoding: UTF-8

class PriceList::Parser::Example < PriceList::Parser

  self.responsible_base_url = "www.example.com"

  def parse
    doc = Nokogiri::HTML(open(self.url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE))
    self.title = doc.xpath('//title').children.text.strip
    self.price = BigDecimal.new(doc.css('div.price').attr('content').value.strip)
    self.stock_state = doc.css('.stockStatus').children.text.strip
    self.currency = '€'
  end
end
```
## Requirements

### Recomended

* Ruby Version > 2.0

### Optional

* GNUPlot

## Todo

* I18n for the UI
