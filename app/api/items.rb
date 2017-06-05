# encoding: UTF-8
require 'csv'
class PriceList::Api::Items < Grape::API
  version 'v1', using: :path
  format :json
  content_type :json, 'application/json;charset=UTF-8'

  ##########
  ## List ##
  ##########
  resource :lists do
    desc('Return all available lists',       entity: PriceList::Entities::List,
                                             params: PriceList::Entities::List.documentation,
                                             is_array: true)
    get :available do
      present(
        List.available,
        with: PriceList::Entities::List
      )
    end

    desc('Return all available lists including corresponding items',       entity: PriceList::Entities::ListWithItems,
                                                                           params: PriceList::Entities::ListWithItems.documentation,
                                                                           is_array: true)
    get 'available/with_items' do
      present(
        List.available.preload(available_items: [:last_price_changes, suppliers: :last_price_changes]),

        with: PriceList::Entities::ListWithItems
      )
    end
  end

  ###########
  ## Items ##
  ###########
  resource :items do
    desc('Return all available items',       entity: PriceList::Entities::Item,
                                             params: PriceList::Entities::Item.documentation,
                                             is_array: true)
    get :available do
      present(
        Item.available.preload(:last_price_changes, suppliers: :last_price_changes),
        with: PriceList::Entities::Item
      )
    end
    get 'available/without_list' do
      present(
        Item.available.without_list.preload(:last_price_changes, :suppliers),
        with: PriceList::Entities::Item
      )
    end

    desc('Return all ItemPrices as csv',         entity: PriceList::Entities::ItemPrice,
                                                 params: PriceList::Entities::ItemPrice.documentation,
                                                 is_array: true)
    get :all do
      content_type 'text/plain;charset=UTF-8'
      rows = ActiveRecord::Base.connection.select_rows(Item.available.joins(:item_prices).to_sql)
      CSV(str = '', col_sep: ';') do |csv|
        csv << (Item.columns.map(&:name) + ItemPrice.columns.map(&:name))
        rows.each { |row| csv << row }
      end
      env['api.format'] = :binary
      str
    end
  end
end
