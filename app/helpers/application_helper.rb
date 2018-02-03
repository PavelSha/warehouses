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
    p = Product.find(id_p) rescue nil
    raise "Product #{id_p} not found" if p.nil?

    w = Warehouse.find(id_w) rescue nil
    raise "Warehouse #{id_w} not found" if w.nil?

    h = History.where(['product_id = ?', id_p]).last

    unless h.nil?
      id_old = h.warehouse_now_id
      w_old = Warehouse.find(id_old)
      w_old.count -= 1
      w_old.save
    end

    h = History.create_record(id_p, id_old, id_w)

    w.count += 1
    w.save

    h
  end

  def pop_product(id_p)
    p = Product.find(id_p) rescue nil
    raise "Product #{id_p} not found" if p.nil?

    p = History.where(['product_id = ?', id_p]).last
    raise "Product #{id_p} not found in history" if p.nil?

    History.create_record(id_p, p.warehouse_now_id, nil)
  end

  def pop_full_product(id_p)
    p = pop_product(id_p)

    remove_product(id_p) unless p.nil?
  end

  def get_empty_warehouses(params)
    c = 0
    Warehouse.find_each do |w|
      next unless w.count == 0

      unless params and params[:skip]
        puts "Name: #{w.name}"
        puts "Address: #{w.address}"
        puts "Area: #{w.area}"
        puts ' -------------------------- '
      end
      c += 1
    end
    c
  end
end
