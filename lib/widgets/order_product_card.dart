import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback? onTap;
  final ProductService _productService = ProductService();

  CartItemCard({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format currency (Vietnamese Dong)
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return FutureBuilder<Product?>(
      future: _productService.getProductByProductId(item.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _buildErrorCard("Product not found");
        }

        final product = snapshot.data!;

        // Find the size from the product
        final size = product.sizes.firstWhere(
          (size) => size.sizeId == item.sizeId,
          orElse: () =>
              ProductSize(sizeId: '', sizeName: 'Standard', extraPrice: 0),
        );

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Quantity indicator
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: Text(
                        "${item.quantity}x",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Product image
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(product.productImg),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Size: ${size.sizeName}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                            height: 4), // Thêm khoảng cách giữa sizeName và giá
                        Text(
                          currencyFormatter.format(item.unitPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFD0000),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Quantity indicator
            SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Text(
                  "${item.quantity}x",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Placeholder for image
            Container(
              width: 70,
              height: 70,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 16),

            // Placeholder for product details
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Loading...",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Size: Loading..."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Quantity indicator
            SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Text(
                  "${item.quantity}x",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Placeholder for image
            Container(
              width: 70,
              height: 70,
              color: Colors.grey[300],
              child: const Icon(Icons.error_outline),
            ),
            const SizedBox(width: 16),

            // Error message
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
