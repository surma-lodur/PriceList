# encoding: UTF-8
require 'csv'
class PriceList::Api::Items < Grape::API
  version 'v1', using: :path
  format :json
  content_type :json, 'application/json;charset=UTF-8'

  resource :items do
    desc('Return all available items',       entity: PriceList::Entities::Item,
                                             params: PriceList::Entities::Item.documentation,
                                             is_array: true)
    get :available do
      present(
        PriceList::Models::Item.available.preload(:last_price_changes),
        with: PriceList::Entities::Item
      )
    end

    desc('Return all ItemPrices as csv',         entity: PriceList::Entities::ItemPrice,
                                                 params: PriceList::Entities::ItemPrice.documentation,
                                                 is_array: true)
    get :all do
      content_type 'text/plain;charset=UTF-8'
      rows = ActiveRecord::Base.connection.select_rows(PriceList::Models::Item.available.joins(:item_prices).to_sql)
      CSV(str = '', col_sep: ';') do |csv|
        csv << (PriceList::Models::Item.columns.map(&:name) + PriceList::Models::ItemPrice.columns.map(&:name))
        rows.each { |row| csv << row }
      end
      env['api.format'] = :binary
      str
    end
  end
end
