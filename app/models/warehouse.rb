class Warehouse < ApplicationRecord
  class << self
    def create_record(n, ad, ar)
      w = Warehouse.new(name: n, address: ad, count: 0, area: ar)
      w.save
    end

    def delete_record(id)
      pr = Warehouse.delete(id)
      pr.save
    end
  end
end
