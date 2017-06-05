# encoding: UTF-8
class StartSchema < ActiveRecord::Migration[4.2]
  def up
    create_table :items do |t|
      t.string :title
      t.string :url#, uniq: true
      t.string :state
      t.string :parser_class
      t.timestamps
    end
    create_table :item_prices do |t|
      t.decimal :price
      t.string  :currency
      t.string  :stock_state
      t.timestamps
    end
    add_reference(:item_prices, :item)
  rescue => e
    puts 'already migrated'
  end

  def down
    drop_table :items
    drop_table :item_prices
  end
end
