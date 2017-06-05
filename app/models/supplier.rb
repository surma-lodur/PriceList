# encoding: UTF-8
class Supplier < ActiveRecord::Base
  include ActiveModel::Transitions


  state_machine(auto_scopes: true) do
    state :available
    state :disabled

    event :disable do
      transitions to: :disabled, from: [:available]
    end
    event :enable do
      transitions to: :available, from: [:disabled]
    end
  end

  belongs_to :item
  has_many(:item_prices, dependent: :destroy)
  has_many(:last_price_changes, -> {
    order('created_at DESC').limit(10) 
  }, foreign_key: 'supplier_id', class_name:'ItemPrice')

  validates :url, uniqueness: true, presence: true

  delegate(
    :favicon_url,
    to: :parser_constant
  )


  after_initialize :set_parser, :execute_parser, unless: :persisted?

  def execute_parser
    puts self.url
    self.item.title = parser.title if parser.title.present?
    if item_prices.blank? || !(-0.01..0.01).include?(item_prices.last.price - (parser.price || 0))

      price = item_prices.build(price:       (parser.price || last_price_changes.try(:price) || 0),
                                stock_state: parser.stock_state,
                                item:        self.item,
                                supplier:    self,
                                currency:    parser.currency)
      if !price.valid?
        price.destroy
      elsif self.persisted?
        save
        touch
        self.item.plot_price_chart!
      end
    end
  rescue => e
    puts "#{id} #{item.title}"
    puts e.class
    puts e
    pp e.backtrace
  end

  def parser_constant
    parser_class.constantize
  end

  def parser
    parser_constant.new(url)
  end

  def set_parser
    self.parser_class = PriceList::Parser.responsible_class_name(self.url)
    
  end # #set_parser

  class << self

    def refetch_prices
      available.each(&:execute_parser)
    end
  end # class
end
