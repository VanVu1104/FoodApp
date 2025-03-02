import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    try {
      // Fetch products by categoryId
      QuerySnapshot productSnapshot = await _firestore
          .collection("products")
          .get();

      List<Product> products = productSnapshot.docs.map((doc) {
        return Product.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Fetch sizes for each product
      for (var product in products) {
        QuerySnapshot sizeSnapshot = await _firestore
            .collection("products")
            .doc(product.productId)
            .collection("size")
            .get();

        product.sizes = sizeSnapshot.docs
            .map((doc) => ProductSize.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }

      return products;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      // Fetch products by categoryId
      QuerySnapshot productSnapshot = await _firestore
          .collection("products")
          .where("categoryId", isEqualTo: categoryId)
          .get();

      List<Product> products = productSnapshot.docs.map((doc) {
        return Product.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Fetch sizes for each product
      for (var product in products) {
        QuerySnapshot sizeSnapshot = await _firestore
            .collection("products")
            .doc(product.productId)
            .collection("size") // Fetch from subcollection
            .get();

        product.sizes = sizeSnapshot.docs
            .map((doc) => ProductSize.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }

      return products;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  String formatCurrency(num amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(amount);
  }
}