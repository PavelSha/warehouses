require 'rails_helper'

RSpec.describe Product, :type => :model do
  it "create a record" do
    add_product("Beef", 0, 1)
    p = Product.find(1)
    expect(p.name).to match(/^Beef$/)
    expect(p.unit).to eq(0)
    expect(p.type_pack).to eq(1)
  end

  it "remove prodcut" do
    add_product("Beef", 0, 1)
    remove_product(1)
    expect {
      Product.find(1)
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

RSpec.describe Warehouse, :type => :model do
  it "create a record" do
    add_warehouse("The Best", "Department of State" + "\n" +
        "4150 Sydney Place" + "\n" +
        "Washington, DC 20521-4150", 23.75)
    w = Warehouse.find(1)
    expect(w.name).to match(/^The Best$/)
    expect(w.address).to match(/^Department of State\n4150 Sydney Place\nWashington, DC 20521-4150$/)
    expect(w.area).to eq(23.75)
    expect(w.count).to eq(0)
  end

  it "remove warehouse" do
    add_warehouse("The Best", "Department of State" + "\n" +
        "4150 Sydney Place" + "\n" +
        "Washington, DC 20521-4150", 23.75)
    remove_warehouse(1)
    expect {
      Warehouse.find(1)
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

RSpec.describe History, :type => :model do
  it "no create without relations" do
    expect {
      push_product(1, 1)
    }.to raise_error("Product 1 not found")

    add_product("Beef", 0, 1)
    expect {
      push_product(1, 1)
    }.to raise_error("Warehouse 1 not found")
  end

  it "no create for duplicates" do
    add_product("Beef", 0, 1)
    add_warehouse("The Best", "Department of State" + "\n" +
        "4150 Sydney Place" + "\n" +
        "Washington, DC 20521-4150", 23.75)
    push_product(1, 1)
    h = push_product(1, 1)
    expect(h).to be_nil
  end

  context " create with one warehouse" do
    before(:each) do
      add_product("Beef", 0, 1)
      add_warehouse("The Best", "Department of State" + "\n" +
          "4150 Sydney Place" + "\n" +
          "Washington, DC 20521-4150", 23.75)
    end

    it " create with one warehouse" do
      h = push_product(1, 1)
      expect(h.product_id).to eq(1)
      expect(h.warehouse_was_id).to be_nil
      expect(h.warehouse_now_id).to eq(1)

      w = Warehouse.find(h.warehouse_now_id)
      expect(w.count).to eq(1)
    end

    it " pop_product" do
      push_product(1, 1)
      h = pop_product(1)

      expect(h.product_id).to eq(1)
      expect(h.warehouse_was_id).to eq(1)
      expect(h.warehouse_now_id).to be_nil

      w = Warehouse.find(h.warehouse_was_id)
      expect(w.count).to eq(0)
    end

    it " pop full product" do
      push_product(1, 1)
      pop_full_product(1)

      expect {
        Product.find(1)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it " create with two warehouses" do
    add_product("Beef", 0, 1)
    add_warehouse("The Best", "Department of State" + "\n" +
        "4150 Sydney Place" + "\n" +
        "Washington, DC 20521-4150", 23.75)
    add_warehouse("The Best2", "Department of State" + "\n" +
        "4140 Sydney Place" + "\n" +
        "Washington, DC 20521-4140", 53.75)
    push_product(1, 1)
    h = push_product(1, 2)
    expect(h.product_id).to eq(1)
    expect(h.warehouse_was_id).to eq(1)
    expect(h.warehouse_now_id).to eq(2)

    w = Warehouse.find(h.warehouse_was_id)
    expect(w.count).to eq(0)

    w = Warehouse.find(h.warehouse_now_id)
    expect(w.count).to eq(1)
  end

  context "get empty warehouses" do
    before(:each) do
      add_product("Beef", 0, 1)
      add_product("The chairs", 1, 1)
      add_product("Pork", 0, 1)
      add_product("The apples", 1, 0)
      add_product("The knifes", 1, 0)
      add_warehouse("The Best", "Department of State" + "\n" +
          "4150 Sydney Place" + "\n" +
          "Washington, DC 20521-4150", 23.75)
      add_warehouse("The best warehouse", "Department of State" + "\n" +
          "4140 Sydney Place" + "\n" +
          "Washington, DC 20521-4140", 53.75)
      add_warehouse("Welcome", "Department of State" + "\n" +
          "4130 Sydney Place" + "\n" +
          "Washington, DC 20521-4130", 73.75)
      add_warehouse("Free", "Department of State" + "\n" +
          "4120 Sydney Place" + "\n" +
          "Washington, DC 20521-4120", 2.99)
      add_warehouse("The five stars", "Department of State" + "\n" +
          "4110 Sydney Place" + "\n" +
          "Washington, DC 20521-4110", 15.75)
    end

    it "without time" do
      push_product(1, 4)
      push_product(4, 2)
      push_product(3, 4)
      push_product(2, 3)
      push_product(3, 1)
      push_product(3, 3)
      push_product(1, 3)
      ar = get_empty_warehouses(0, 0, 0, 0, 0, {:skip => true})
      expect(ar).to match_array([1, 4, 5])
      expect(ar).not_to match_array([2, 3])
    end

    it "with time" do
      Warehouse.record_timestamps = false
      w = Warehouse.find(1)
      w.updated_at = Time.now - 8.day
      w.save
      w = Warehouse.find(2)
      w.updated_at = Time.now - 8.day
      w.save
      w = Warehouse.find(3)
      w.updated_at = Time.now - 8.day
      w.save
      w = Warehouse.find(4)
      w.updated_at = Time.now - 8.day
      w.save
      w = Warehouse.find(5)
      w.updated_at = Time.now - 8.day
      w.save
      Warehouse.record_timestamps = true

      push_product(1, 4)
      Warehouse.record_timestamps = false
      w = Warehouse.find(4)
      w.updated_at = Time.now - 7.day
      w.save
      Warehouse.record_timestamps = true

      push_product(4, 2)
      Warehouse.record_timestamps = false
      w = Warehouse.find(2)
      w.updated_at = Time.now - 6.day
      w.save
      Warehouse.record_timestamps = true

      push_product(3, 4)
      Warehouse.record_timestamps = false
      w = Warehouse.find(4)
      w.updated_at = Time.now - 5.day
      w.save
      Warehouse.record_timestamps = true

      push_product(2, 3)
      Warehouse.record_timestamps = false
      w = Warehouse.find(3)
      w.updated_at = Time.now - 4.day
      w.save
      Warehouse.record_timestamps = true

      push_product(3, 1)
      Warehouse.record_timestamps = false
      w = Warehouse.find(1)
      w.updated_at = Time.now - 3.day
      w.save
      w = Warehouse.find(4)
      w.updated_at = Time.now - 3.day
      w.save
      Warehouse.record_timestamps = true

      push_product(3, 3)
      Warehouse.record_timestamps = false
      w = Warehouse.find(3)
      w.updated_at = Time.now - 2.day
      w.save
      w = Warehouse.find(1)
      w.updated_at = Time.now - 2.day
      w.save
      Warehouse.record_timestamps = true

      push_product(1, 3)
      Warehouse.record_timestamps = false
      w = Warehouse.find(3)
      w.updated_at = Time.now
      w.save
      w = Warehouse.find(4)
      w.updated_at = Time.now
      w.save
      Warehouse.record_timestamps = true

      ar = get_empty_warehouses(0, 0, 2, 0, 0, {:skip => true})
      expect(ar).to match_array([1, 5])

    end
  end

  it " get paths of the products" do
    add_product("Beef", 0, 1)
    add_product("The chairs", 1, 1)
    add_product("Pork", 0, 1)
    add_product("The apples", 1, 0)
    add_product("The knifes", 1, 0)
    add_product("Gold", 1, 1)
    add_product("The matches", 0, 0)
    add_warehouse("The Best", "Department of State" + "\n" +
        "4150 Sydney Place" + "\n" +
        "Washington, DC 20521-4150", 23.75)
    add_warehouse("The best warehouse", "Department of State" + "\n" +
        "4140 Sydney Place" + "\n" +
        "Washington, DC 20521-4140", 53.75)
    add_warehouse("Welcome", "Department of State" + "\n" +
        "4130 Sydney Place" + "\n" +
        "Washington, DC 20521-4130", 73.75)
    add_warehouse("Free", "Department of State" + "\n" +
        "4120 Sydney Place" + "\n" +
        "Washington, DC 20521-4120", 2.99)
    add_warehouse("The five stars", "Department of State" + "\n" +
        "4110 Sydney Place" + "\n" +
        "Washington, DC 20521-4110", 15.75)
    push_product(1, 4)
    push_product(5, 3)
    push_product(4, 2)
    push_product(5, 2)
    push_product(5, 1)
    push_product(3, 4)
    push_product(5, 4)
    push_product(5, 5)
    push_product(2, 3)
    push_product(5, 3)
    push_product(3, 1)
    push_product(3, 3)
    push_product(1, 3)
    push_product(5, 2)
    push_product(5, 3)

    ar = get_path_product(1, {:skip => true})
    expect(ar).to match_array([4, 3])
    ar = get_path_product(2, {:skip => true})
    expect(ar).to match_array([3])
    ar = get_path_product(3, {:skip => true})
    expect(ar).to match_array([4, 1, 3])
    ar = get_path_product(4, {:skip => true})
    expect(ar).to match_array([2])
    ar = get_path_product(5, {:skip => true})
    expect(ar).to match_array([3, 2, 1, 4, 5, 3, 2, 3])
    ar = get_path_product(6, {:skip => true})
    expect(ar).to match_array([])

    pop_product(2)
    ar = get_path_product(2, {:skip => true})
    expect(ar).to match_array([3])
  end

  context "" do
    before(:each) do
      add_product("Beef", 0, 1)
      add_product("The chairs", 1, 1)
      add_product("Pork", 0, 1)
      add_product("The apples", 1, 0)
      add_product("The knifes", 1, 0)
      add_product("Gold", 1, 1)
      add_product("The matches", 0, 0)
      add_warehouse("The Best", "Department of State" + "\n" +
          "4150 Sydney Place" + "\n" +
          "Washington, DC 20521-4150", 23.75)
      add_warehouse("The best warehouse", "Department of State" + "\n" +
          "4140 Sydney Place" + "\n" +
          "Washington, DC 20521-4140", 53.75)
      add_warehouse("Welcome", "Department of State" + "\n" +
          "4130 Sydney Place" + "\n" +
          "Washington, DC 20521-4130", 73.75)
      add_warehouse("Free", "Department of State" + "\n" +
          "4120 Sydney Place" + "\n" +
          "Washington, DC 20521-4120", 2.99)
      add_warehouse("The five stars", "Department of State" + "\n" +
          "4110 Sydney Place" + "\n" +
          "Washington, DC 20521-4110", 15.75)
      add_warehouse("Temp", "Department of State" + "\n" +
          "4100 Sydney Place" + "\n" +
          "Washington, DC 20521-4100", 1.1)

      push_product(1, 4)

      History.record_timestamps = false
      h = History.find(1)
      h.created_at = Time.now - 13.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(5, 3)

      History.record_timestamps = false
      h = History.find(2)
      h.created_at = Time.now - 12.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(4, 2)

      History.record_timestamps = false
      h = History.find(3)
      h.created_at = Time.now - 11.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(5, 2)

      History.record_timestamps = false
      h = History.find(4)
      h.created_at = Time.now - 9.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(5, 1)

      History.record_timestamps = false
      h = History.find(5)
      h.created_at = Time.now - 9.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(3, 4)

      History.record_timestamps = false
      h = History.find(6)
      h.created_at = Time.now - 8.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(5, 4)

      History.record_timestamps = false
      h = History.find(7)
      h.created_at = Time.now - 8.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(5, 5)

      History.record_timestamps = false
      h = History.find(8)
      h.created_at = Time.now - 8.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(2, 3)

      History.record_timestamps = false
      h = History.find(9)
      h.created_at = Time.now - 8.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(5, 3)

      History.record_timestamps = false
      h = History.find(10)
      h.created_at = Time.now - 5.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(3, 1)

      History.record_timestamps = false
      h = History.find(11)
      h.created_at = Time.now - 4.month - 1.hour
      h.save
      History.record_timestamps = true

      h = push_product(3, 3)

      History.record_timestamps = false
      h = History.find(12)
      h.created_at = Time.now - 3.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(1, 3)

      History.record_timestamps = false
      h = History.find(13)
      h.created_at = Time.now - 1.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(5, 2)

      History.record_timestamps = false
      h = History.find(14)
      h.created_at = Time.now - 1.month - 1.hour
      h.save
      History.record_timestamps = true

      push_product(5, 3)

      History.record_timestamps = false
      h = History.find(15)
      h.created_at = Time.now
      h.save
      History.record_timestamps = true
    end

    it "get intensity" do
      res = get_intensity(12, {:skip => true})
      expect(res).to include({1 => 1.0, 2 => 0.67, 3 => 0.4, 4 => 1.5, 5 => 1.0})

      expect {
        get_intensity(-1, {:skip => true})
      }.to raise_error('the number of the months should be greater than zero')
      expect {
        get_intensity(0, {:skip => true})
      }.to raise_error('the number of the months should be greater than zero')

      res = get_intensity(3, {:skip => true})
      expect(res).to include({2 => 1.0, 3 => 0.5})
    end

    it "get history product" do
      ar = get_history_product(1, 0, 0, 0, 0, 12, {:skip => true})
      expect(ar).to match_array([3])
      ar = get_history_product(1, 0, 0, 0, 0, 15, {:skip => true})
      expect(ar).to match_array([4, 3])
      ar = get_history_product(6, 0, 0, 0, 0, 15, {:skip => true})
      expect(ar).to match_array([])
      ar = get_history_product(5, 0, 0, 0, 0, 10, {:skip => true})
      expect(ar).to match_array([2, 1, 4, 5, 3, 2, 3])
    end
  end

  # TODO: pop_product
  # TODO: pop_full_product
end