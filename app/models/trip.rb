class Trip < ActiveRecord::Base
  has_many :hotels
  has_many :activities

  validates_presence_of :description, :start_date, :end_date, :price, :tag_line

  def calculate_fee(discounted_price, amount)
    trip_fee(amount) + time_fee
  end

  def trip_fee(amount)
    10 * amount
  end

  def time_fee
    ((2013 - start_date.year)) / 100
  end
end
