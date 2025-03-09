import 'package:demo_firebase/models/product.dart';
import 'package:demo_firebase/screens/cart/empty_cart_screen.dart';
import 'package:demo_firebase/screens/menu_screen.dart';
import 'package:demo_firebase/screens/product_detail_screen.dart';
import 'package:demo_firebase/services/cart_service.dart';
import 'package:demo_firebase/services/product_service.dart';
import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:demo_firebase/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _cartService.getCartItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomLoading();
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: customAppBar(context, 'Giỏ hàng'),
            body: Center(
              child: Text('Lỗi: ${snapshot.error}'),
            ),
          );
        }

        // Hide AppBar when cart is empty
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyCartScreen();
        }

        // Show AppBar with items
        final cartItems = snapshot.data!.docs;

        return Scaffold(
          appBar: customAppBar(context, 'Giỏ hàng'),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final data = item.data() as Map<String, dynamic>;

                    return Dismissible(
                      key: Key(item.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        try {
                          // Remove the item and get its data for potential restoration
                          final removedItemData =
                              await _cartService.removeFromCart(item.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${data['productName']} đã bị xóa khỏi giỏ hàng'),
                              action: SnackBarAction(
                                label: 'HOÀN TÁC',
                                onPressed: () async {
                                  try {
                                    // Restore the deleted item
                                    await _cartService.undoRemoveFromCart(
                                        item.id, removedItemData);

                                    // Optionally show a confirmation message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Đã hoàn tác thành công')),
                                    );

                                    // If needed, refresh your UI
                                    setState(() {});
                                  } catch (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Không thể hoàn tác: $error')),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $error')),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data['productImg'] ?? '',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, _) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product name and edit icon in same row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          data['productName'] ??
                                              'Unknown Product',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFFFFC115),
                                          size: 22,
                                        ),
                                        onPressed: () async {
                                          // First, get the product details from the product ID in the cart item
                                          final productId = data['productId'];
                                          try {
                                            // Fetch the product from your product service
                                            final productDoc =
                                                await FirebaseFirestore.instance
                                                    .collection('products')
                                                    .doc(productId)
                                                    .get();
                                            if (!productDoc.exists) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Không thể tìm thấy thông tin sản phẩm')),
                                              );
                                              return;
                                            }

                                            // Convert to Product object
                                            final product =
                                                await _productService
                                                    .getProductByProductId(
                                                        productId);

                                            // Navigate to the product detail page in edit mode
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductDetailScreen(
                                                  product: product!,
                                                  color: Colors.red,
                                                  isEditingCart: true,
                                                  cartItemId: item.id,
                                                  initialSizeId: data['sizeId'],
                                                  initialQuantity:
                                                      data['quantity'],
                                                ),
                                              ),
                                            );
                                          } catch (error) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text('Lỗi: $error')),
                                            );
                                          }
                                        },
                                        constraints: BoxConstraints.tight(
                                            const Size(24, 24)),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    data['sizeName'] ?? '',
                                    style: TextStyle(
                                      color: Color(0xFF655E5E),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Price and quantity controls in same row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _productService.formatCurrency(
                                            data['unitPrice'] ?? 0),
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Quantity controls
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              int currentQty =
                                                  data['quantity'] ?? 1;
                                              if (currentQty > 1) {
                                                _cartService
                                                    .updateCartItemQuantity(
                                                        item.id,
                                                        currentQty - 1);
                                              } else {
                                                _showRemoveItemDialog(item.id,
                                                    data['productName']);
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.red),
                                              ),
                                              child: const Icon(
                                                Icons.remove,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${data['quantity'] ?? 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              int currentQty =
                                                  data['quantity'] ?? 1;
                                              _cartService
                                                  .updateCartItemQuantity(
                                                      item.id, currentQty + 1);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.red),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom summary and checkout section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Item count and total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số lượng món ăn',
                          style:
                              TextStyle(fontSize: 16, color: Color(0xFF655E5E)),
                        ),
                        Text(
                          '${cartItems.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TỔNG TIỀN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF655E5E),
                          ),
                        ),
                        FutureBuilder<double>(
                          future: _cartService.getCartTotal(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(
                                  strokeWidth: 2);
                            }

                            final total = snapshot.data ?? 0.0;
                            return Text(
                              _productService.formatCurrency(total),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Two buttons row
                    Row(
                      children: [
                        // Add Items Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MenuScreen(
                                            color: Color(0xFFF00000),
                                          )));
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Thêm món',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Checkout Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    // Checkout functionality will be implemented later
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              _isLoading ? 'Đang xử lý...' : 'Đặt món',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRemoveItemDialog(String itemId, String? productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có muốn xóa $productName khỏi giỏ hàng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cartService.removeFromCart(itemId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }
}

// Add this extension method to CartService
extension CartServiceExtension on CartService {
  Future<int> getCartItemCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('carts').get();
    return snapshot.docs.length;
  }
}
