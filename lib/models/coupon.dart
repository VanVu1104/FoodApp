class Coupon {
  final String couponId;
  final String couponName;
  final String couponImageUrl;
  final double discountValue;
  final bool isPercentage;
  final DateTime expiredDate;
  final double minPurchaseAmount;
  final double? maxDiscountValue;
  final CouponType type;

  Coupon({
    required this.couponId,
    required this.couponName,
    required this.couponImageUrl,
    required this.discountValue,
    required this.isPercentage,
    required this.expiredDate,
    required this.minPurchaseAmount,
    this.maxDiscountValue,
    required this.type,
  });
}

enum CouponType {
  order, // Giảm giá vào tổng tiền hàng
  shipping, // Giảm giá vào phí ship
}
