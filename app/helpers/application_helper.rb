module ApplicationHelper
  def add_product(n, u, t)
    Product.create_record(n, u, t)
  end

  def add_warehouse(n, ad, ar)
    Warehouse.create_record(n, ad, ar)
  end

  def remove_product(id)
    Product.delete_record(id)
  end

  def remove_warehouse(n, ad, ar)
    Warehouse.delete_record(id)
  end

  def push_product(id_p, id_w)
    p = History.where(["product_id = ?", id_p]).last

    id_old = p.warehouse_now_id unless p.nil?

    History.create_record(id_p, id_old, id_w)
  end

  def pop_product(id_p)
    p = History.where(["product_id = ?", id_p]).last

    unless p.nil?
      History.create_record(id_p, p.warehouse_now_id, nil)
    else
      puts('Product not found')
      nil
    end
  end

  def pop_full_product(id_p)
    p = pop_product(id_p)

    remove_product(id_p) unless p.nil?
  end
end
