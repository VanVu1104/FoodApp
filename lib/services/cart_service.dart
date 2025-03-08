import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get cart reference for the current user
  CollectionReference _getCartRef() {
    return _firestore.collection('users').doc(currentUserId).collection('cart');
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
    final selectedSize =
        product.sizes.firstWhere((size) => size.sizeId == selectedSizeId);

    // Check if the item already exists in the cart
    final existingCartItem = await _getCartRef()
        .where('productId', isEqualTo: product.productId)
        .where('sizeId', isEqualTo: selectedSizeId)
        .get();

    if (existingCartItem.docs.isNotEmpty) {
      // Update existing cart item
      final docId = existingCartItem.docs.first.id;
      final existingQuantity =
          existingCartItem.docs.first.get('quantity') as int;

      await _getCartRef().doc(docId).update({
        'quantity': existingQuantity + quantity,
        'totalPrice': (existingCartItem.docs.first.get('unitPrice') as double) *
            (existingQuantity + quantity),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Add new cart item
      await _getCartRef().add({
        'productId': product.productId,
        'productName': product.productName,
        'productImg': product.productImg,
        'sizeId': selectedSizeId,
        'sizeName': selectedSize.sizeName,
        'unitPrice':
            (product.productPrice + selectedSize.extraPrice).toDouble(),
        'quantity': quantity,
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get cart items
  Stream<QuerySnapshot> getCartItems() {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }
    return _getCartRef().orderBy('createdAt', descending: true).snapshots();
  }

  // Get cart total
  Future<double> getCartTotal() async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final cartItems = await _getCartRef().get();
    double total = 0;
    for (var item in cartItems.docs) {
      total += (item.get('totalPrice') as double);
    }
    return total;
  }

  // Remove item from cart
  Future<Map<String, dynamic>> removeFromCart(String cartItemId) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Get the item data before deleting it
    final documentSnapshot = await _getCartRef().doc(cartItemId).get();
    if (!documentSnapshot.exists) {
      throw Exception('Cart item not found');
    }

    final itemData = documentSnapshot.data() as Map<String, dynamic>;

    // Delete the item
    await _getCartRef().doc(cartItemId).delete();

    // Return the item data so it can be used for undo
    return itemData;
  }

  // Add a new method to restore a deleted cart item
  Future<void> undoRemoveFromCart(
      String cartItemId, Map<String, dynamic> itemData) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Restore the item with the same ID
    await _getCartRef().doc(cartItemId).set(itemData);
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final cartItem = await _getCartRef().doc(cartItemId).get();
    final unitPrice = cartItem.get('unitPrice') as double;

    await _getCartRef().doc(cartItemId).update({
      'quantity': quantity,
      'totalPrice': unitPrice * quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

// Edit cart item - change size and/or quantity
  Future<void> editCartItem({
    required String cartItemId,
    required String selectedSizeId,
    required String sizeName,
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
      'sizeName': sizeName,
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
