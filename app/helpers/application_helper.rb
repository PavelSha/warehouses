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

  def get_intensity(m, params)
    raise 'the number of the months should be greater than zero' unless m > 0

    time_mount = 60 * 60 * 24 * 30
    time_now = Time.now
    k = {}
    Warehouse.find_each do |w|
      qnext = 0
      qlast = 0
      History.find_each do |h|
        next if h.warehouse_was_id != w.id && h.warehouse_now_id != w.id
        next if h.created_at.utc < time_now.utc - m * time_mount

        qnext += 1 if h.warehouse_was_id == w.id
        qlast += 1 if h.warehouse_now_id == w.id
      end
      unless qlast == 0
        k[w.id] = (qnext.to_f / qlast.to_f).round(2)
      else
        puts "The warehouse #{w.id} wasn't used for #{m} month(s)." unless params and params[:skip]
      end
    end
    k
  end

  # If time is null, it don't use
  def get_history_product(id_p, params, sec = 0, min = 0, h = 0, d = 0, m = 0)
    ar = []
    dur = Time.now - ((sec + 60 * (min + 60 * h)) + d.to_i.days + + m.to_i.month)
    History.find_each do |h|
      next unless h.product_id == id_p
      next if h.created_at.utc < dur.utc && (sec != 0 || min != 0 || h != 0 || d != 0 || m != 0)

      ar.push(h.warehouse_now_id) unless h.warehouse_now_id.nil?

      unless params and params[:skip]
        str_from = ''
        unless h.warehouse_was_id.nil?
          w = Warehouse.find(h.warehouse_was_id)
          str_from += w.name
        end
        str_to = ''
        unless h.warehouse_now_id.nil?
          w = Warehouse.find(h.warehouse_now_id)
          str_to += w.name
        end
        h.warehouse_now_id.nil?
        puts "From: #{str_from}"
        puts "To: #{str_to}"
        puts "Date: #{h.created_at.inspect}"
        puts ' -------------------------- '
      end
    end
    ar
  end

end
