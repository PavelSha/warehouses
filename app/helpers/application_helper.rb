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

  # If time is null, it don't use
  def get_empty_warehouses(params, sec = 0, min = 0, h = 0)
    ar = []
    dur = Time.now - (sec + 60 * (min + 60 * h))
    Warehouse.find_each do |w|
      next unless w.count == 0
      next if w.updated_at.utc >= dur.utc && (sec != 0 || min != 0 || h != 0)

      unless params and params[:skip]
        puts "Name: #{w.name}"
        puts "Address: #{w.address}"
        puts "Area: #{w.area}"
        puts ' -------------------------- '
      end
      ar.push(w.id)
    end
    ar
  end

  def get_path_product(id_p, params)
    ar = []
    str = ""
    History.find_each do |h|
      next unless h.product_id == id_p

      unless h.warehouse_now_id.nil?
        str += " -> #{h.warehouse_now_id}"
        ar.push(h.warehouse_now_id)
      else
        str += ' -> '
      end
    end
    puts str unless params and params[:skip]
    ar
  end

end
