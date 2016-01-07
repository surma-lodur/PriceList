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

  has_many :item_prices, dependent: :destroy
  belongs_to :list

  has_many(:last_price_changes, -> { order('created_at DESC').limit(10) }, class_name: 'PriceList::Models::ItemPrice', foreign_key: 'item_id')

  before_create :execute_parser

  validates :url, uniqueness: true

  def execute_parser
    parser = parser_class.constantize.new(url)
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
      end
    end
  rescue => e
    puts "#{id} #{title}"
    puts e
    pp e.backtrace
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
