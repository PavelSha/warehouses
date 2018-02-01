class Product < ApplicationRecord
  class << self
    def create_record(n, u, t)
      pr = Product.new(name: n, unit: u, type_pack: t)
      pr.save
    end

    def delete_record(id)
      pr = Product.delete(id)
      pr.save
    end
  end
end
