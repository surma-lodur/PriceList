# encoding: UTF-8
class CreateLists < ActiveRecord::Migration[4.2]
  def up
    create_table :lists do |t|
      t.string :title
      t.timestamps
    end
    add_reference(:items, :list)
  rescue => e
    puts 'already migrated'
  end

  def down
    drop_table :lists
    remove_column :items, :list_id
  end
end
