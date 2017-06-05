# encoding: UTF-8
class CreateSuppliers < ActiveRecord::Migration[4.2]

  def up
    create_table :suppliers do |t|
      t.string :url#, uniq: true
      t.string :state
      t.string :parser_class
      t.timestamps
    end
    add_reference(:suppliers, :item)
    add_reference(:item_prices, :supplier)

    Item.all.each do |item|
      supplier = item.suppliers.new({
        url:          item.url,
        parser_class: item.parser_class,
        state:        item.state
      })
      supplier.save!
      item.item_prices.update_all(supplier_id: supplier.id)
    end
    change_table :items do |t|
      t.remove :url
      t.remove :parser_class
    end
  rescue => e
    puts 'already migrated'
  end

  def down
    drop_table :suppliers
    remove_reference(:item_prices, :supplier)
  end
end
