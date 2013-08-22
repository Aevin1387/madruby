class PurchasesOrder
  def initialize(trip_id, hotel_id, activity_ids, length_of_stay)
    @trip_id, @hotel_id, @activity_ids, @length_of_stay = trip_id, hotel_id, activity_ids, length_of_stay
  end

  def trip
    @trip ||= Trip.find(@trip_id)
  end

  def hotel
    @hotel ||= Hotel.find(@trip_id)
  end

  def activities
    @activities ||= @activity_ids.map { |id| Activity.find(id) }
  end

  def order
    @order ||= Order.new
  end

  def trip_fee(trip, amount)
    10 * amount + (((2013 - trip.start_date.year)) / 100)
  end

  def hotel_fee(hotel, amount)
    (hotel.price > 250 ? 10 : 0)
  end

  def activity_fee(activity, amount)
    5 * amount
  end

  def add_line_item(buyable, unit_price, amount)
    extended_price = unit_price * amount
    processing_fee = buyable.calculate_fee(amount)
    order.order_line_items.new(buyable: buyable,
      unit_price: unit_price,
      amount: amount,
      extended_price: extended_price,
      processing_fee: processing_fee,
      price_paid: extended_price + processing_fee
      )
  end

  def total_price(order)
    order.order_line_items.map(&:price_paid).sum
  end

  def run
    add_line_item(trip, trip.price, 1)
    add_line_item(hotel, hotel.price, @length_of_stay.to_i)
    activities.each { |a| add_line_item(a, a.price, 1) }
    order.total_price_paid = total_price(order)
    order.save
  end
end
