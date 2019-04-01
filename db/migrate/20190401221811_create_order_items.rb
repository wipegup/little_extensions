class CreateOrderItems < ActiveRecord::Migration[5.1]
  def change
    create_table :order_items do |t|
      t.references :orders, foreign_key: true
      t.references :items, foreign_key: true
      t.integer :quantity
      t.money :ordered_price
      t.boolean :fulfilled, default: false

      t.timestamps
    end
  end
end
