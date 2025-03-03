import 'package:demo_firebase/models/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Color color;

  const ProductDetailScreen(
      {super.key, required this.product, required this.color});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedSizeId;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    // Set the first size as default if available

    selectedSizeId = widget.product.sizes.first.sizeId;
  }

  double get totalPrice {
    double basePrice = widget.product.productPrice.toDouble();
    double extraPrice = 0;

    final selectedSize = widget.product.sizes
        .firstWhere((size) => size.sizeId == selectedSizeId);

    extraPrice = selectedSize.extraPrice.toDouble();

    return (basePrice + extraPrice) * quantity;
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
      body: Stack(
        children: [
          // Product image with red background
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.05),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // Enables horizontal scrolling
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: widget.product.sizes.map<Widget>((size) {
                              final bool isSelected = selectedSizeId == size.sizeId;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedSizeId = size.sizeId;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected ? Colors.red : Colors.grey[300]!,
                                        width: isSelected ? 2 : 2.5,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        size.sizeName,
                                        style: TextStyle(
                                          color: isSelected ? Colors.red : Colors.grey[500],
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

                        // Quantity selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Align items to center
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
                                  shape: BoxShape.circle, // Make it circular
                                  border: Border.all(
                                      color: Colors.red,
                                      width: 2), // Red border
                                ),
                                child: const Icon(Icons.remove,
                                    color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 10), // Spacing

                            // Quantity Display
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red, // Red background
                              ),
                              child: Center(
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    // Adjust font size for better visibility
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10), // Spacing

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
                                  shape: BoxShape.circle, // Make it circular
                                  border: Border.all(
                                      color: Colors.red,
                                      width: 2), // Red border
                                ),
                                child:
                                    const Icon(Icons.add, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const SizedBox(height: 16),

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
                      ],
                    ),

                    const Spacer(),

                    // Total price and add to cart button
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Tổng tiền",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                ProductService().formatCurrency(totalPrice),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Add to cart functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.color,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.shopping_cart, color: Colors.white),
                            label: const Text("Thêm vào giỏ", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Image.network(
              height: height * 0.3,
              widget.product.productImg,
            ),
          ),
        ],
      ),
    );
  }
}
