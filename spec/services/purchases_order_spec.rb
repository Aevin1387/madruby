require "spec_helper"

describe PurchasesOrder do
  let!(:mayflower) { Trip.create!(
      :name => "Mayflower Luxury Cruise",
      :tag_line => "Enjoy The Cruise That Started It All",
      :start_date => "September 6, 1620",
      :end_date => "November 21, 1620",
      :location => "Atlantic Ocean",
      :tag => "Cruising",
      :image_name => "mayflower.jpg",
      :description => "You'll take a scenic 66 day, 67 night cruise from England to Cape Cod. Come for the scurvy, stay for the starvation",
      :price => 1200) }

  before do
    Hotel.create!(
        :trip => mayflower,
        :name => "Deluxe Suite",
        :description => "A luxury suite. On the Mayflower. Really.",
        :price => 500,
        :remote_api_id => "abc123")

    Activity.create!(
        :trip => mayflower,
        :name => "Martha's Vineyard",
        :description => "Tour Martha's Vineyard",
        :price => 400)

    Activity.create!(
        :trip => mayflower,
        :name => "Special Boat Tour",
        :description => "Tour The Whole Boat",
        :price => 300)
  end

  it "applies a discount to the hotel" do
    coupon_code = CouponCode.create(discount_percentage: 60, applies_to: "hotels", code: "ABC123")
    PurchasesOrder.new(mayflower.id, Hotel.first.id, Activity.all.map(&:id), 4, coupon_code.code).run
    order = Order.last
    expect(order.hotel_item.extended_price).to eq(800)
    expect(order.hotel_item.processing_fee).to eq(0)
  end

  it "applies an all discount to everything" do
    coupon_code = CouponCode.create(discount_percentage: 60, applies_to: "all", code: "ABC123")
    PurchasesOrder.new(mayflower.id, Hotel.first.id, Activity.all.map(&:id), 4, coupon_code.code).run
    order = Order.last
    expect(order.hotel_item.extended_price).to eq(800)
    expect(order.trip_item.extended_price).to eq(480)
    expect(order.activity_items.first.extended_price).to eq(160)
    expect(order.activity_items.last.extended_price).to eq(120)
    expect(order.total_price_paid).to eq(1583)
  end

  it "does not apply fees if the discount is 100%" do
    coupon_code = CouponCode.create(discount_percentage: 100, applies_to: "all", code: "ABC123")
    PurchasesOrder.new(mayflower.id, Hotel.first.id, Activity.all.map(&:id), 4, coupon_code.code).run
    order = Order.last
    expect(order.total_price_paid).to eq(0)
  end
end
