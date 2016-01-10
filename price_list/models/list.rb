# encoding: UTF-8
class PriceList::Models::List < ActiveRecord::Base

  self.table_name = 'lists'

  has_many :items, dependent: :destroy
  has_many(:available_items, -> { available }, class_name: 'PriceList::Models::Item', foreign_key: 'list_id')

  validates :title, uniqueness: true, presence: true

  class << self
    # TODO add transitions
    def available
      self.where("id IS NOT NULL")
    end
  end
end
