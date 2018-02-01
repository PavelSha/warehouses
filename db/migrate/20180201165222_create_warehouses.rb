class CreateWarehouses < ActiveRecord::Migration[5.1]
  def change
    create_table :warehouses do |t|
      t.text :name
      t.text :address
      t.boolean :availability
      t.float :area

      t.timestamps
    end
  end
end
