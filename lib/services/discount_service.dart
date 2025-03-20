import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/models/coupon.dart';

class DiscountService {
  Future<List<Coupon>> getCouponsByUserId(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print("User not found");
        return [];
      }

      List<dynamic> couponIds = userDoc.get('couponId') ?? [];

      if (couponIds.isEmpty) {
        print("No coupons found for user.");
        return [];
      }

      // Step 3: Fetch coupons details using the coupon IDs
      QuerySnapshot couponDocs = await FirebaseFirestore.instance
          .collection('coupons')
          .where(FieldPath.documentId, whereIn: couponIds)
          .get();

      List<Coupon> coupons = couponDocs.docs.map((doc) {
        return Coupon.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return coupons;
    } catch (e) {
      print("Error fetching coupons for user $userId: $e");
      return [];
    }
  }

  bool isValid(DateTime expiredDate, num fee, double minPurchaseAmount) {
    final currentDate = DateTime.now();

    if (currentDate.isAfter(expiredDate)) return false;
    if (fee < minPurchaseAmount) return false;
    return true;
  }

  double getDiscountPrice(double subTotal, double deliveryFee, CouponType type,
      bool isPercentage, double discountValue, double? maxDiscountValue) {
    double discountAmount = 0.0;
    double applicableAmount =
        (type == CouponType.order) ? subTotal : deliveryFee;

    // Calculate discount
    discountAmount =
        isPercentage ? applicableAmount * (discountValue / 100) : discountValue;

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
