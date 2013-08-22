class Hotel < ActiveRecord::Base
  belongs_to :trip

  def calculate_fee(days)
     price_fee
  end

  def price_fee
    (price > 250 ? 10 : 0)
  end
end
