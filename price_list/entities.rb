# encoding: UTF-8
# https://github.com/ruby-grape/grape-entity/blob/master/README.md
module PriceList::Entities
  class ItemPrice < Grape::Entity
    expose :price
    expose :currency
    expose :created_at
    expose :stock_state
  end

  class Item < Grape::Entity
    expose :id
    expose :title,       documentation: { type: 'string', desc: 'Title of the article' }
    expose :favicon_url, documentation: {type: 'url', desc: 'Favicon of the watched site'}
    expose :updated_at
    expose :price_chart_url
    expose :url,         documentation: {type: 'url', desc: 'Site of the item watched'}
    expose :last_price_changes, using: PriceList::Entities::ItemPrice
    expose :last_price, using: PriceList::Entities::ItemPrice do |item|
      item.last_price_changes.first
    end
  end
end
