require "spec_helper"

describe "purchasing a trip" do

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

  describe "basic process" do
    it "creates order and line item objects" do
      visit("/trips/#{mayflower.id}")
      select('4', :from => 'length_of_stay')
      choose("hotel_id_#{mayflower.hotels.first.id}")
      check("activity_id_#{mayflower.activities.first.id}")
      click_button("Order")
      order = Order.last
      expect(order.order_line_items.count).to eq(3)
      expect(order.order_line_items.map(&:buyable)).to eq(
          [mayflower, mayflower.hotels.first, mayflower.activities.first])
    end
  end

  it "correctly puts pricing in the line item objects" do
    visit("/trips/#{mayflower.id}")
    select('4', :from => 'length_of_stay')
    choose("hotel_id_#{mayflower.hotels.first.id}")
    check("activity_id_#{mayflower.activities.first.id}")
    click_button("Order")
    order = Order.last
    expect(order.trip_item.unit_price).to eq(1200)
    expect(order.trip_item.amount).to eq(1)
    expect(order.trip_item.extended_price).to eq(1200)
    expect(order.trip_item.processing_fee).to eq(13)
    expect(order.hotel_item.unit_price).to eq(500)
    expect(order.hotel_item.amount).to eq(4)
    expect(order.hotel_item.extended_price).to eq(2000)
    expect(order.hotel_item.processing_fee).to eq(10)
    expect(order.activity_items.first.unit_price).to eq(400)
    expect(order.activity_items.first.amount).to eq(1)
    expect(order.activity_items.first.extended_price).to eq(400)
    expect(order.activity_items.first.processing_fee).to eq(5)
    expect(order.total_price_paid).to eq(3628)
  end

end
