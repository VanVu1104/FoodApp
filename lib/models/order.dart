import 'package:demo_firebase/models/address.dart';

import 'cart_item.dart';
import 'coupon.dart';

class Order {
  final String orderId;
  final String userId;
  final String? orderCouponId;
  final String? shippingCouponId;
  final Address pickUpAddress;
  final Address? deliveryAddress;
  final List<CartItem> listCartItem;
  final double deliveryFee;
  final double? orderDiscount;
  final double? deliveryDiscount;
  final bool rewardDiscount;
  final double rewardedPoint;
  final String paymentMethod;
  final double totalPrice;
  final String note;
  final String status;
  final int ratedBar; // rated from 1 to 5
  final String feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order(
    this.orderId,
    this.userId,
    this.orderCouponId,
    this.shippingCouponId,
    this.pickUpAddress,
    this.deliveryAddress,
    this.listCartItem,
    this.deliveryFee,
    this.orderDiscount,
    this.deliveryDiscount,
    this.rewardDiscount,
    this.rewardedPoint,
    this.paymentMethod,
    this.totalPrice,
    this.note,
    this.status,
    this.ratedBar,
    this.feedback,
    this.createdAt,
    this.updatedAt,
  );
}
