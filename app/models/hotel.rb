class Hotel < ActiveRecord::Base
  belongs_to :trip

  def calculate_fee(discounted_price, days)
     price_fee(discounted_price)
  end

  def price_fee(discounted_price)
    (discounted_price > 250 ? 10 : 0)
  end
end
