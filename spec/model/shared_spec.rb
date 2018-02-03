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

  # TODO: pop_product
  # TODO: pop_full_product
end