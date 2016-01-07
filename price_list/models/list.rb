# encoding: UTF-8
class PriceList::Models::List < ActiveRecord::Base
  include ActiveModel::Transitions

  self.table_name = 'lists'
  
  has_many :items, dependent: :destroy
end
