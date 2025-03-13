import 'package:demo_firebase/models/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../utils/utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Color color;
  // New parameters for edit mode
  final bool isEditingCart;
  final String? cartItemId;
  final String? initialSizeId;
  final int? initialQuantity;
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.color,
    this.isEditingCart = false,
    this.cartItemId,
    this.initialSizeId,
    this.initialQuantity,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedSizeId;
  int quantity = 1;
  bool _isProcessing = false;
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    // Use initial values if editing cart item, otherwise use defaults
    if (widget.isEditingCart && widget.initialSizeId != null) {
      selectedSizeId = widget.initialSizeId;
      quantity = widget.initialQuantity ?? 1;
    } else {
      // Set the first size as default if available
      selectedSizeId = widget.product.sizes.first.sizeId;
    }
  }

  double get totalPrice {
    return _cartService.calculateTotalPrice(
      product: widget.product,
      selectedSizeId: selectedSizeId!,
      quantity: quantity,
    );
  }

  // Handle add to cart or update cart
  Future<void> _handleCartAction() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      if (widget.isEditingCart) {
        await _cartService.updateCartItemWithFeedback(
          product: widget.product,
          cartItemId: widget.cartItemId!,
          selectedSizeId: selectedSizeId!,
          quantity: quantity,
          context: context,
        );
      } else {
        await _cartService.addToCartWithFeedback(
          product: widget.product,
          selectedSizeId: selectedSizeId!,
          quantity: quantity,
          totalPrice: totalPrice,
          context: context,
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: widget.color,
      appBar: AppBar(
        backgroundColor: widget.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Main content - scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  // This Column contains the image and the white background
                  Column(
                    children: [
                      // Space for the product image
                      SizedBox(height: height * 0.2),

                      // White background container
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Add space for the overlapping image
                            SizedBox(height: height * 0.1),

                            // Product name
                            Text(
                              widget.product.productName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Preparation time and calories
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer, color: Colors.blue, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.product.productPreparationTime} phút",
                                  style: const TextStyle(color: Colors.blue),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.local_fire_department,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.product.productCalo} kcal",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Size selection
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: widget.product.sizes.map<Widget>((size) {
                                  final bool isSelected =
                                      selectedSizeId == size.sizeId;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedSizeId = size.sizeId;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.red
                                                : Colors.grey[300]!,
                                            width: isSelected ? 2 : 2.5,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.white,
                                        ),
                                        child: Center(
                                          child: Text(
                                            size.sizeName,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.red
                                                  : Colors.grey[500],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Description header
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Mô tả",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Description
                                Text(
                                  widget.product.productDescription,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  "Ghi chú",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextField(
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: "",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(color: Colors.black45, width: 2.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white, // Background color
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ],
                            ),

                            // Add extra space at the bottom for scrolling
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Product image - positioned on top and will scroll with content
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.network(
                        widget.product.productImg,
                        height: height * 0.3,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed bottom container - not scrollable
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tổng tiền",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      Utils().formatCurrency(totalPrice),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Decrease Button
                        InkWell(
                          onTap: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.red,
                                  width: 2),
                            ),
                            child: const Icon(Icons.remove, color: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Quantity Display
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Increase Button
                        InkWell(
                          onTap: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.red,
                                  width: 2),
                            ),
                            child: const Icon(Icons.add, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _handleCartAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Set border radius here
                        ),
                      ),
                      child: Text(
                          _isProcessing
                              ? "Đang xử lý..."
                              : widget.isEditingCart ? "Cập nhật" : "Thêm vào giỏ",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}