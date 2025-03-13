import 'package:demo_firebase/models/cart.dart';
import 'package:demo_firebase/models/product.dart';
import 'package:demo_firebase/screens/cart/empty_cart_screen.dart';
import 'package:demo_firebase/screens/menu_screen.dart';
import 'package:demo_firebase/screens/order_screen.dart';
import 'package:demo_firebase/screens/product_detail_screen.dart';
import 'package:demo_firebase/services/cart_service.dart';
import 'package:demo_firebase/services/product_service.dart';
import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:demo_firebase/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/utils.dart';

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
    // Get screen dimensions for responsive layout
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final bool isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final double imageSize = isSmallScreen ? 80 : 100;

    return StreamBuilder<List<CartItem>>(
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

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyCartScreen();
        }

        final cartItems = snapshot.data!;

        return Scaffold(
          appBar: customAppBar(context, 'Giỏ hàng'),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];

                      return FutureBuilder<Product?>(
                        future: _productService
                            .getProductByProductId(cartItem.productId),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final product = productSnapshot.data;
                          final productName =
                              product?.productName ?? 'Unknown Product';
                          final productImg =
                              product?.productImg.isNotEmpty == true
                                  ? product!.productImg
                                  : '';

                          final selectedSize = product?.sizes.firstWhere(
                            (size) => size.sizeId == cartItem.sizeId,
                            orElse: () => ProductSize(
                              sizeId: '',
                              sizeName: 'Unknown Size',
                              extraPrice: 0,
                            ),
                          );
                          final sizeName = selectedSize?.sizeName ?? '';

                          return Dismissible(
                            key: Key(cartItem.cartItemId),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async {
                              try {
                                final removedItem = await _cartService
                                    .removeFromCart(cartItem.cartItemId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '$productName đã bị xóa khỏi giỏ hàng'),
                                    action: SnackBarAction(
                                      label: 'HOÀN TÁC',
                                      onPressed: () async {
                                        try {
                                          await _cartService
                                              .undoRemoveFromCart(removedItem);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Đã hoàn tác thành công')),
                                          );

                                          // If needed, refresh your UI
                                          setState(() {});
                                        } catch (error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
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
                              padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 8 : 12,
                                  horizontal: isSmallScreen ? 8 : 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      productImg,
                                      width: imageSize,
                                      height: imageSize,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, error, _) =>
                                          Container(
                                        width: imageSize,
                                        height: imageSize,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                            Icons.image_not_supported),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? 8 : 16),

                                  // Product details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Product name and edit icon in same row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                productName,
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 14 : 16,
                                                  fontWeight: FontWeight.bold,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                maxLines: 2,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Color(0xFFFFC115),
                                                size: 22,
                                              ),
                                              onPressed: () async {
                                                if (product == null) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Không thể tìm thấy thông tin sản phẩm')),
                                                  );
                                                  return;
                                                }

                                                // Navigate to the product detail page in edit mode
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductDetailScreen(
                                                      product: product,
                                                      color: Colors.red,
                                                      isEditingCart: true,
                                                      cartItemId:
                                                          cartItem.cartItemId,
                                                      initialSizeId:
                                                          cartItem.sizeId,
                                                      initialQuantity:
                                                          cartItem.quantity,
                                                    ),
                                                  ),
                                                );
                                              },
                                              constraints: BoxConstraints.tight(
                                                  const Size(24, 24)),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          sizeName,
                                          style: TextStyle(
                                            color: const Color(0xFF655E5E),
                                            fontSize: isSmallScreen ? 10 : 12,
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 4 : 8),
                                        // Price and quantity controls in same row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                Utils().formatCurrency(cartItem
                                                    .unitPrice
                                                    .toDouble()),
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      isSmallScreen ? 14 : 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Quantity controls
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    if (cartItem.quantity > 1) {
                                                      _cartService
                                                          .updateCartItemQuantity(
                                                              cartItem
                                                                  .cartItemId,
                                                              cartItem.quantity -
                                                                  1);
                                                    } else {
                                                      _showRemoveItemDialog(
                                                          cartItem.cartItemId,
                                                          productName);
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        isSmallScreen ? 1 : 2),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Colors.red),
                                                    ),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: isSmallScreen
                                                          ? 14
                                                          : 16,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: isSmallScreen
                                                          ? 4
                                                          : 8),
                                                  width:
                                                      isSmallScreen ? 20 : 24,
                                                  height:
                                                      isSmallScreen ? 20 : 24,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${cartItem.quantity}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: isSmallScreen
                                                            ? 12
                                                            : 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    _cartService
                                                        .updateCartItemQuantity(
                                                            cartItem.cartItemId,
                                                            cartItem.quantity +
                                                                1);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        isSmallScreen ? 1 : 2),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Colors.red),
                                                    ),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: isSmallScreen
                                                          ? 14
                                                          : 16,
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
                      );
                    },
                  ),
                ),

                // Bottom summary and checkout section
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                          Text(
                            'Số lượng món ăn',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: const Color(0xFF655E5E)),
                          ),
                          Text(
                            '${cartItems.length}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TỔNG TIỀN',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF655E5E),
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
                                Utils().formatCurrency(total),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      // Two buttons row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Use vertical arrangement for very small screens
                          if (constraints.maxWidth < 280) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildAddItemsButton(context),
                                const SizedBox(height: 8),
                                _buildCheckoutButton(context),
                              ],
                            );
                          } else {
                            // Use horizontal arrangement for larger screens
                            return Row(
                              children: [
                                // Add Items Button
                                Expanded(child: _buildAddItemsButton(context)),
                                SizedBox(width: isSmallScreen ? 8 : 12),
                                // Checkout Button
                                Expanded(child: _buildCheckoutButton(context)),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Extract button widgets for reusability
  Widget _buildAddItemsButton(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuScreen(
              color: const Color(0xFFF00000),
            ),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        'Thêm món',
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderScreen(),
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        _isLoading ? 'Đang xử lý...' : 'Đặt món',
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showRemoveItemDialog(String itemId, String productName) {
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
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('cart')
        .get();

    return snapshot.docs.length;
  }
}
