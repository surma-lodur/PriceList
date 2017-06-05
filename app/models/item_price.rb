# encoding: UTF-8
class ItemPrice < ActiveRecord::Base
  belongs_to :item
  belongs_to :supplier
  validates  :price, :supplier, :item, :currency, presence: true
end
