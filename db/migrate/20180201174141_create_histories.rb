class CreateHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :histories do |t|
      t.integer :product_id
      t.integer :warehouse_was_id
      t.integer :warehouse_now_id

      t.timestamps
    end
  end
end
