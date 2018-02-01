class AddCountToWarehouses < ActiveRecord::Migration[5.1]
  def change
    add_column :warehouses, :count, :integer
  end
end
