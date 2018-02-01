class RemoveAvailabilityFromWarehouses < ActiveRecord::Migration[5.1]
  def change
    remove_column :warehouses, :availability, :boolean
  end
end
