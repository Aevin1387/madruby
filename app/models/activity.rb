class Activity < ActiveRecord::Base
  belongs_to :trip

  def calculate_fee(discounted_price, amount)
    5 * amount
  end
end
