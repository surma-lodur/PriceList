# encoding: UTF-8
class Item < ActiveRecord::Base
  include ActiveModel::Transitions

  state_machine(auto_scopes: true) do
    state :available
    state :disabled

    event :disabled do
      transitions to: :disabled, from: [:available]
    end
  end

  belongs_to :list
  has_many   :suppliers, dependent: :destroy

  has_many(  :item_prices, dependent: :destroy)
  has_many(  :last_price_changes, -> {
    order('created_at DESC').limit(10) 
  }, {
    foreign_key: 'item_id',
    class_name:  'ItemPrice'
  })


  validates(:list, :presence => {
    :if => :list_id
  })

  delegate(
    :favicon_url,
    :url,
    to: :cheapest_supplier,
    allow_nil: true
  )

  scope :without_list, lambda {
    where(list_id: nil)
  }


  def cheapest_supplier
    self.suppliers.first
  end # #cheapest_supplier

  def price_chart_url
    PriceList::PriceChart.chart_path(self).gsub(File.join(PriceList::Root, 'public'), '')
  end

  def plot_price_chart!
    PriceList::PriceChart.plot_item(self)
  end

  class << self
    def create_from_url(url, list_id = nil)
      item = self.new(list_id: list_id)
 supp=     item.suppliers.build(item: item, url: url)
 pp supp.item.title
      item.save!
      return item
    end

    def refetch_prices
      available.each(&:execute_parser)
    end
  end # class
end
