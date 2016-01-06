# encoding: UTF-8
class PriceList::Models::ItemPrice < ActiveRecord::Base
  self.table_name = 'item_prices'
  belongs_to :item
  validates  :price, :currency, presence: true
end
