require 'rails_helper'

RSpec.describe Product, :type => :model do
  it "create a record" do
    add_product("Beef", 0, 1)
    p = Product.find(1)
    expect(p.name).to match(/^Beef$/)
    expect(p.unit).to eq(0)
    expect(p.type_pack).to eq(1)
  end
  # TODO: remove_product
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
  # TODO: remove_warehouse
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

  it " create with one warehouse" do
    add_product("Beef", 0, 1)
    add_warehouse("The Best", "Department of State" + "\n" +
        "4150 Sydney Place" + "\n" +
        "Washington, DC 20521-4150", 23.75)
    h = push_product(1, 1)
    expect(h.product_id).to eq(1)
    expect(h.warehouse_was_id).to be_nil
    expect(h.warehouse_now_id).to eq(1)

    w = Warehouse.find(h.warehouse_now_id)
    expect(w.count).to eq(1)
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
      ar = get_empty_warehouses({:skip => true})
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

      push_product(1, 4)
      w = Warehouse.find(4)
      w.updated_at = Time.now - 7.day
      w.save

      push_product(4, 2)
      w = Warehouse.find(2)
      w.updated_at = Time.now - 6.day
      w.save

      push_product(3, 4)
      w = Warehouse.find(4)
      w.updated_at = Time.now - 5.day
      w.save

      push_product(2, 3)
      w = Warehouse.find(3)
      w.updated_at = Time.now - 4.day
      w.save

      push_product(3, 1)
      w = Warehouse.find(1)
      w.updated_at = Time.now - 3.day
      w.save
      w = Warehouse.find(4)
      w.updated_at = Time.now - 3.day
      w.save

      push_product(3, 3)
      w = Warehouse.find(3)
      w.updated_at = Time.now - 2.day
      w.save
      w = Warehouse.find(1)
      w.updated_at = Time.now - 2.day
      w.save

      push_product(1, 3)
      w = Warehouse.find(3)
      w.updated_at = Time.now
      w.save
      w = Warehouse.find(4)
      w.updated_at = Time.now
      w.save

      ar = get_empty_warehouses({:skip => true}, 0, 0, 2)
      expect(ar).to match_array([1, 5])

      Warehouse.record_timestamps = true
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

  # TODO: pop_product
  # TODO: pop_full_product
end