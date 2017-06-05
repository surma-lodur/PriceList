# encoding: UTF-8
# https://github.com/ruby-grape/grape-entity/blob/master/README.md
module PriceList::Entities
  class ItemPrice < Grape::Entity
    expose :price,       documentation: { type: 'float', desc: 'price as float' }
    expose :currency,    documentation: { type: 'string', desc: 'currency sym' }
    expose :created_at
    expose :stock_state, documentation: { type: 'string', desc: 'availability to the time from the record' }
  end

  class Supplier < Grape::Entity 
    expose :id
    expose :favicon_url,      documentation: {type: 'url', desc: 'Favicon of the watched site'}
    expose :state
    expose :updated_at do |supplier|
      supplier.last_price_changes.first.try(:updated_at)
    end
    expose :url,              documentation: {type: 'url', desc: 'Site of the item watched'}
    expose :last_price_changes, using: PriceList::Entities::ItemPrice
    expose :last_price, using: PriceList::Entities::ItemPrice do |supplier|
      supplier.last_price_changes.first
    end
  end

  class Item < Grape::Entity
    expose :id
    expose :list_id
    expose :title,            documentation: { type: 'string', desc: 'Title of the article' }
    expose :favicon_url,      documentation: {type: 'url', desc: 'Favicon of the watched site'}
    expose :updated_at do |item|
      item.last_price_changes.first.try(:updated_at)
    end
    expose :price_chart_url,  documentation: {type: 'url', desc: 'relative url to the generated price chart'}
    expose :url,              documentation: {type: 'url', desc: 'Site of the item watched'}
#    expose :last_price_changes, using: PriceList::Entities::ItemPrice
    expose :last_price, using: PriceList::Entities::ItemPrice do |item|
      item.last_price_changes.first
    end
    expose :suppliers, using: PriceList::Entities::Supplier
  end

  class List < Grape::Entity
    expose :id
    expose :title,            documentation: { type: 'string', desc: 'Title of the list' }
  end

  class ListWithItems < Grape::Entity
    expose :id
    expose :title,            documentation: { type: 'string', desc: 'Title of the list' }
    expose :available_items,  using: PriceList::Entities::Item
  end
end
