class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.text :name
      t.integer :unit
      t.integer :type_pack

      t.timestamps
    end
  end
end
