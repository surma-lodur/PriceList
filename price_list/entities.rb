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
    expose :title, documentation: { type: 'string', desc: 'Title of the article' }
    expose :updated_at
    expose :url
    expose :last_price_changes, using: PreisListe::Entities::ItemPrice
  end
end
