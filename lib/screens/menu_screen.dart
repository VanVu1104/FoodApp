import 'package:demo_firebase/screens/product_detail_screen.dart';
import 'package:demo_firebase/widgets/custom_loading.dart';
import 'package:demo_firebase/widgets/product_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/custom_app_bar.dart';

class MenuScreen extends StatefulWidget {
  final String? categoryId;
  final Color color;

  const MenuScreen({super.key, this.categoryId, required this.color});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();

    if (widget.categoryId != null) {
      _productsFuture =
          _productService.getProductsByCategory(widget.categoryId ?? '');
    } else {
      _productsFuture = _productService.getProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context, 'Thực đơn'),
      body: Column(
        children: [
          // Products List
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomLoading();
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading products"));
                }
                final products = snapshot.data ?? [];

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      // Exactly 2 items per row
                      childAspectRatio: 0.6,
                      // Adjusted for the card's proportions
                      crossAxisSpacing: 25,
                      // Horizontal spacing between cards
                      mainAxisSpacing: 25, // Vertical spacing between cards
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final item = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                      product: item,
                                      color: widget.color)));
                        },
                        child: ProductCardWidget(
                          product: item,
                          isFavorite: false,
                          onFavoriteTapped: () {
                            setState(() {
                              // item['isFavorite'] = !item['isFavorite'];
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
