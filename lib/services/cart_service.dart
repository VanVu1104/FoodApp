import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/models/cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:flutter/material.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get cart reference for the current user
  CollectionReference _getCartRef() {
    return _firestore.collection('users').doc(currentUserId).collection('cart');
  }

  // Calculate total price based on product, size, and quantity
  double calculateTotalPrice({
    required Product product,
    required String selectedSizeId,
    required int quantity,
  }) {
    double basePrice = product.productPrice.toDouble();
    final selectedSize = getSelectedSize(
      product: product,
      selectedSizeId: selectedSizeId,
    );
    double extraPrice = selectedSize.extraPrice.toDouble();

    return (basePrice + extraPrice) * quantity;
  }

  // Get selected size information
  ProductSize getSelectedSize({
    required Product product,
    required String selectedSizeId,
  }) {
    return product.sizes.firstWhere((size) => size.sizeId == selectedSizeId);
  }

  // Add product to cart with UI feedback
  Future<void> addToCartWithFeedback({
    required Product product,
    required String selectedSizeId,
    required int quantity,
    required double totalPrice,
    required BuildContext context,
  }) async {
    if (selectedSizeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn kích thước')),
      );
      return;
    }

    try {
      await addToCart(
        product: product,
        selectedSizeId: selectedSizeId,
        quantity: quantity,
        totalPrice: totalPrice,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${product.productName} vào giỏ hàng'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Update cart item with UI feedback
  Future<void> updateCartItemWithFeedback({
    required Product product,
    required String cartItemId,
    required String selectedSizeId,
    required int quantity,
    required BuildContext context,
  }) async {
    if (selectedSizeId.isEmpty || cartItemId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lỗi: Thiếu thông tin kích thước hoặc mã giỏ hàng')),
      );
      return;
    }

    try {
      // Get the selected size information
      final selectedSize = getSelectedSize(
        product: product,
        selectedSizeId: selectedSizeId,
      );

      // Calculate unit price with the selected size
      final unitPrice =
          (product.productPrice + selectedSize.extraPrice).toDouble();

      // Convert to CartItem
      final cartItem = CartItem(
        cartItemId: cartItemId,
        productId: product.productId,
        sizeId: selectedSizeId,
        unitPrice: unitPrice,
        quantity: quantity,
        totalPrice: unitPrice * quantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Update cart item
      await updateCartItem(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật ${product.productName} trong giỏ hàng'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Return to the cart page
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Add product to cart
  Future<void> addToCart({
    required Product product,
    required String selectedSizeId,
    required int quantity,
    required double totalPrice,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Find the selected size from the product
    final selectedSize = getSelectedSize(
      product: product,
      selectedSizeId: selectedSizeId,
    );

    // Check if the item already exists in the cart
    final existingCartQuery = await _getCartRef()
        .where('productId', isEqualTo: product.productId)
        .where('sizeId', isEqualTo: selectedSizeId)
        .get();

    if (existingCartQuery.docs.isNotEmpty) {
      // Update existing cart item
      final doc = existingCartQuery.docs.first;
      final docId = doc.id;
      final data = doc.data() as Map<String, dynamic>;

      // Create CartItem from existing document
      final existingCartItem = CartItem.fromJson(docId, data);

      // Create updated cart item
      final updatedCartItem = CartItem(
        cartItemId: docId,
        productId: existingCartItem.productId,
        sizeId: existingCartItem.sizeId,
        unitPrice: existingCartItem.unitPrice,
        quantity: existingCartItem.quantity + quantity,
        totalPrice:
            existingCartItem.unitPrice * (existingCartItem.quantity + quantity),
        createdAt: existingCartItem.createdAt,
        updatedAt: DateTime.now(),
      );

      // Update cart item
      await updateCartItem(updatedCartItem);
    } else {
      // Create new cart item
      final unitPrice =
          (product.productPrice + selectedSize.extraPrice).toDouble();
      final now = DateTime.now();

      final newCartItem = CartItem(
        cartItemId: '', // This will be assigned by Firestore
        productId: product.productId,
        sizeId: selectedSizeId,
        unitPrice: unitPrice,
        quantity: quantity,
        totalPrice: totalPrice,
        createdAt: now,
        updatedAt: now,
      );

      // Add to cart
      await _getCartRef().add(newCartItem.toJson());
    }
  }

  // Get cart items as stream of CartItem objects
  Stream<List<CartItem>> getCartItems() {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    return _getCartRef().orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) =>
                CartItem.fromJson(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get cart total
  Future<double> getCartTotal() async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final cartItems = await _getCartRef().get();
    double total = 0;
    for (var doc in cartItems.docs) {
      final item =
          CartItem.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      total += item.totalPrice.toDouble();
    }
    return total;
  }

  // Remove item from cart
  Future<CartItem> removeFromCart(String cartItemId) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Get the item data before deleting it
    final documentSnapshot = await _getCartRef().doc(cartItemId).get();
    if (!documentSnapshot.exists) {
      throw Exception('Cart item not found');
    }

    final data = documentSnapshot.data() as Map<String, dynamic>;
    final cartItem = CartItem.fromJson(cartItemId, data);

    // Delete the item
    await _getCartRef().doc(cartItemId).delete();

    // Return the cart item so it can be used for undo
    return cartItem;
  }

  // Add a new method to restore a deleted cart item
  Future<void> undoRemoveFromCart(CartItem cartItem) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Restore the item with the same ID
    await _getCartRef().doc(cartItem.cartItemId).set(cartItem.toJson());
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final docSnapshot = await _getCartRef().doc(cartItemId).get();
    if (!docSnapshot.exists) {
      throw Exception('Cart item not found');
    }

    final data = docSnapshot.data() as Map<String, dynamic>;
    final cartItem = CartItem.fromJson(cartItemId, data);

    final updatedCartItem = CartItem(
      cartItemId: cartItemId,
      productId: cartItem.productId,
      sizeId: cartItem.sizeId,
      unitPrice: cartItem.unitPrice,
      quantity: quantity,
      totalPrice: cartItem.unitPrice * quantity,
      createdAt: cartItem.createdAt,
      updatedAt: DateTime.now(),
    );

    await updateCartItem(updatedCartItem);
  }

  // Update cart item
  Future<void> updateCartItem(CartItem cartItem) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Remove cartItemId from the data to be saved
    final data = cartItem.toJson();

    // Update the cart item
    await _getCartRef().doc(cartItem.cartItemId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Edit cart item - change size and/or quantity
  Future<void> editCartItem({
    required String cartItemId,
    required String selectedSizeId,
    required double unitPrice,
    required int quantity,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Calculate new total price
    final totalPrice = unitPrice * quantity;

    // Update the cart item with new size and quantity
    await _getCartRef().doc(cartItemId).update({
      'sizeId': selectedSizeId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Clear cart
  Future<void> clearCart() async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final cartItems = await _getCartRef().get();
    for (var item in cartItems.docs) {
      await _getCartRef().doc(item.id).delete();
    }
  }
}