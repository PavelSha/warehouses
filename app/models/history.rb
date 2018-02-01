class History < ApplicationRecord

  class << self
    def create_record(idp, idw1, idw2)
      h = History.new(product_id: idp, warehouse_was_id: idw1, warehouse_now_id: idw2)
      h.save
    end
  end
end
