import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/services/zalopayment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_firebase/services/cart_service.dart';
import 'package:demo_firebase/models/cart.dart';
import 'package:demo_firebase/models/cart_item.dart';
import 'package:flutter/material.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartService _cartService;

  // Reference to the orders collection
  CollectionReference get _ordersRef => _firestore.collection('orders');

  // Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Constructor that takes a CartService instance
  OrderService(this._cartService);

  // Save an order from the current cart
  Future<String> saveOrderFromCart({
    required double totalPrice,
    required String paymentMethod,
    String pickUpAddress = "",
    String deliveryAddress = "",
    double deliveryFee = 0,
    dynamic coupon = null,
    int rewardedPoint = 0,
    String note = "",
  }) async {
    try {
      // Verify user is logged in
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Get current cart
      Cart cart = await _cartService.getOrCreateCart();

      // Verify cart has items
      if (cart.cartItem.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Create Order object from Cart data
      final order = {
        'userId': cart.userId,
        'pickUpAddress': pickUpAddress,
        'deliveryAddress': deliveryAddress,
        'listCartItem': cart.cartItem.map((item) => item.toJson()).toList(),
        'deliveryFee': deliveryFee,
        'coupon': coupon,
        'rewardedPoint': rewardedPoint,
        'paymentMethod': paymentMethod,
        'totalPrice': totalPrice,
        'note': note,
        'status': "processing",
        'ratedBar': 0,
        'feedback': "",
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      // Save order to Firestore
      DocumentReference orderRef = await _ordersRef.add(order);

      print("Order saved with ID: ${orderRef.id}");
      return orderRef.id;
    } catch (e) {
      print("Error saving order: $e");
      throw Exception("Failed to save order: $e");
    }
  }

  // Process payment and create order
  Future<String> processPaymentAndCreateOrder({
    required double totalPrice,
    required String paymentMethod,
    required BuildContext context,
    String pickUpAddress = "",
    String? deliveryAddress = "",
    double deliveryFee = 0,
    dynamic coupon = null,
    int rewardedPoint = 0,
    String note = "",
  }) async {
    bool paymentSuccess = false;

    // Process payment based on selected method
    if (paymentMethod == "zalopay") {
      paymentSuccess = await ZaloPayment.processPayment(context, totalPrice);
    } else if (paymentMethod == "cash") {
      // Cash payment is automatically successful
      paymentSuccess = true;
    }

    // If payment successful, create order and clear cart
    if (paymentSuccess) {
      String orderId = await saveOrderFromCart(
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        pickUpAddress: pickUpAddress,
        deliveryAddress: deliveryAddress!,
        deliveryFee: deliveryFee,
        coupon: coupon,
        rewardedPoint: rewardedPoint,
        note: note,
      );

      // Clear cart after successful order
      await _cartService.clearCart();

      return orderId;
    } else {
      throw Exception("Payment failed");
    }
  }

  // Get orders for current user
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      QuerySnapshot querySnapshot = await _ordersRef
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'orderId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting user orders: $e');
      throw Exception('Failed to get orders: $e');
    }
  }

  // Get specific order by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      DocumentSnapshot orderDoc = await _ordersRef.doc(orderId).get();

      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      return {
        'orderId': orderDoc.id,
        ...orderDoc.data() as Map<String, dynamic>,
      };
    } catch (e) {
      print('Error getting order details: $e');
      throw Exception('Failed to get order details: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersRef.doc(orderId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  // Add rating and feedback to order
  Future<void> addOrderRatingAndFeedback(
      String orderId, double rating, String feedback) async {
    try {
      await _ordersRef.doc(orderId).update({
        'ratedBar': rating,
        'feedback': feedback,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding rating and feedback: $e');
      throw Exception('Failed to add rating and feedback: $e');
    }
  }
}
