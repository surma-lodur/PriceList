# encoding: UTF-8
require 'csv'
class PriceList::Api < Grape::API
  version 'v1', using: :header, vendor: 'lodur'
  format :json

  prefix :api

  content_type :json, 'application/json;charset=UTF-8'
  # formatter :csv, ->(object, env) { object.to_s }
  # default_format :json

  helpers do
  end

  resource :items do
    desc 'Return all available items'
    get :available do
      present(
        PriceList::Models::Item.available.preload(:last_price_changes),
        with: PriceList::Entities::Item
      )
    end

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

  add_swagger_documentation
end
