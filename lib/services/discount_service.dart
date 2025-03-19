import 'package:demo_firebase/models/coupon.dart';

class DiscountService {

  Future<List<Coupon>> getCouponsByUserId(String userId) async {

    final List<Coupon> coupons = [
      Coupon(
        couponId: 'GIAM20K',
        couponName: 'GIAM 20K CHO DON TU 50K',
        couponImageUrl: 'https://dealngon.vn/wp-content/uploads/2024/01/ma-giam-gia-jollibee.jpg',
        discountValue: 20000,
        isPercentage: false,
        expiredDate: DateTime(2025, 12, 1),
        minPurchaseAmount: 50000,
        type: CouponType.order,
      ),
      Coupon(
        couponId: 'GIAM10%',
        couponName: 'GIAM 10% (TOI DA 30K) CHO DON TU 0D',
        couponImageUrl: 'https://dealngon.vn/wp-content/uploads/2024/01/ma-giam-gia-jollibee.jpg',
        discountValue: 10,
        isPercentage: true,
        expiredDate: DateTime(2025, 12, 1),
        minPurchaseAmount: 0,
        maxDiscountValue: 30000,
        type: CouponType.order,
      ),
      Coupon(
        couponId: 'GIAM50%',
        couponName: 'GIAM 50% (TOI DA 30K) CHO DON TU 0D',
        couponImageUrl: 'https://dealngon.vn/wp-content/uploads/2024/01/ma-giam-gia-jollibee.jpg',
        discountValue: 50,
        isPercentage: true,
        expiredDate: DateTime(2025, 12, 1),
        minPurchaseAmount: 0,
        maxDiscountValue: 30000,
        type: CouponType.order,
      ),
      Coupon(
        couponId: 'GIAOHANG10K',
        couponName: 'GIAM 10K PHI VAN CHUYEN CHO DON TU 50K',
        couponImageUrl: 'https://dealngon.vn/wp-content/uploads/2024/01/ma-giam-gia-jollibee.jpg',
        discountValue: 10000,
        isPercentage: false,
        expiredDate: DateTime(2025, 12, 1),
        minPurchaseAmount: 0,
        type: CouponType.shipping,
      ),
      Coupon(
        couponId: 'GIAOHANG20K',
        couponName: 'GIAM 20K PHI VAN CHUYEN CHO DON TU 50K',
        couponImageUrl: 'https://dealngon.vn/wp-content/uploads/2024/01/ma-giam-gia-jollibee.jpg',
        discountValue: 20000,
        isPercentage: false,
        expiredDate: DateTime(2025, 12, 1),
        minPurchaseAmount: 0,
        type: CouponType.shipping,
      ),
    ];

    return coupons;
  }

  bool isValid(DateTime expiredDate, double fee, double minPurchaseAmount) {
    final currentDate = DateTime.now();

    if (currentDate.isAfter(expiredDate)) return false;
    if (fee < minPurchaseAmount) return false;
    return true;
  }

  double getDiscountPrice(
      double subTotal,
      double deliveryFee,
      CouponType type,
      bool isPercentage,
      double discountValue,
      double? maxDiscountValue) {

    double discountAmount = 0.0;
    double applicableAmount = (type == CouponType.order) ? subTotal : deliveryFee;

    // Calculate discount
    discountAmount = isPercentage ? applicableAmount * (discountValue / 100) : discountValue;

    // Ensure discount does not exceed maxDiscountValue
    if (maxDiscountValue != null && discountAmount > maxDiscountValue) {
      discountAmount = maxDiscountValue;
    }

    // Ensure discount does not exceed actual price (subTotal or deliveryFee)
    if (discountAmount > applicableAmount) {
      discountAmount = applicableAmount;
    }

    return discountAmount;
  }
}