class Activity < ActiveRecord::Base
  belongs_to :trip

  def calculate_fee(amount)
    5 * amount
  end
end
