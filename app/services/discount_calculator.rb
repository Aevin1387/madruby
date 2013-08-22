class DiscountCalculator
  attr_reader :buyable, :coupon

  def initialize(buyable, coupon_code)
    @buyable = buyable
    @coupon = CouponCode.find_by(code: coupon_code)
  end

  def applicable?
    coupon.applies_to == "all" || coupon.applies_to == buyable.class.to_s.downcase.pluralize
  end

  def discount_amount
    return 0 unless coupon && applicable?
    (buyable.price * (coupon.discount_percentage / 100.0))
  end
end
