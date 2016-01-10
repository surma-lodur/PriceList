# encoding: UTF-8
class PriceList::Models::Item < ActiveRecord::Base
  include ActiveModel::Transitions

  self.table_name = 'items'

  state_machine(auto_scopes: true) do
    state :available
    state :disabled

    event :disabled do
      transitions to: :disabled, from: [:available, :out_of_stock]
    end
  end

  belongs_to :list

  has_many :item_prices, dependent: :destroy
  has_many(:last_price_changes, -> { order('created_at DESC').limit(10) }, class_name: 'PriceList::Models::ItemPrice', foreign_key: 'item_id')

  before_create :execute_parser

  validates :url, uniqueness: true, presence: true

  delegate(
    :favicon_url,
    :to => :parser_constant
  )

  def execute_parser
    self.title = parser.title
    if item_prices.blank? || !(-0.01..0.01).include?(item_prices.last.price - parser.price)

      price = item_prices.build(price:       parser.price,
                                stock_state: parser.stock_state,
                                currency:    parser.currency)
      if not price.valid?
        price.destroy
      elsif self.persisted?
        self.save
        self.touch
        self.plot_price_chart!
      end
    end
  rescue => e
    puts "#{id} #{title}"
    puts e
    pp e.backtrace
  end

  def parser_constant
    parser_class.constantize
  end

  def parser
    parser_constant.new(url)
  end

  def price_chart_url
    PriceList::PriceChart.chart_path(self).gsub(File.join(PriceList::Root, 'public'), '')
  end

  def plot_price_chart!
    PriceList::PriceChart.plot_item(self)
  end

  class << self
    def create_from_url(url)
      create(url: url, parser_class: PriceList::Parser.responsible_class_name(url))
    end

    def refetch_prices
      available.each(&:execute_parser)
    end
  end # class
end
