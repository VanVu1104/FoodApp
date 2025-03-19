import 'package:demo_firebase/screens/invoice/custom.dart';
import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double containerWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: customAppBar(context, 'Chi tiết hóa đơn'),
      backgroundColor: Colors.white,

      // Use SingleChildScrollView to make the entire content scrollable
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CẢM ƠN BẠN ĐÃ ĐẶT HÀNG!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Đơn hàng của bạn đã được xác nhận và sẽ được vận chuyển ngay lập tức.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Order Items Container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    padding: const EdgeInsets.all(8),
                    width: containerWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFB9B9B9),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    // Use ListView.builder for dynamic product list
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sampleProducts.length,
                      itemBuilder: (context, index) {
                        final product = sampleProducts[index];
                        return OrderItemWidget(
                          title: product['title']!,
                          description: product['description']!,
                          price: product['price']!,
                          imagePath: product['imagePath']!,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(8),
                    width: containerWidth,
                    child: const OrderDetailsWidget(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Total and Button - fixed at bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng tiền',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      calculateTotal(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Quay về trang chủ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sample products list for demonstration
final List<Map<String, String>> sampleProducts = [
  {
    'title': 'Burger thịt hun khói',
    'description': 'Burger thịt hun khói với bacon...',
    'price': '65.000 đ',
    'imagePath': 'assets/burger.png',
  },
  {
    'title': 'Gà sốt mắm tỏi',
    'description': 'Gà rán giòn phủ sốt mắm tỏi...',
    'price': '35.000 đ',
    'imagePath': 'assets/chicken.png',
  },
  {
    'title': 'Khoai tây chiên',
    'description': 'Khoai tây chiên vàng giòn...',
    'price': '30.000 đ',
    'imagePath': 'assets/fries.png',
  },
  // Additional sample items to demonstrate scrolling
  {
    'title': 'Coca Cola',
    'description': 'Nước ngọt có ga...',
    'price': '15.000 đ',
    'imagePath': 'assets/drink.png',
  },
  {
    'title': 'Cánh gà sốt cay',
    'description': 'Cánh gà sốt cay kiểu Buffalo...',
    'price': '45.000 đ',
    'imagePath': 'assets/wings.png',
  },
];

// Calculate total price from all products
String calculateTotal() {
  int total = 0;
  for (var product in sampleProducts) {
    // Extract numeric value from price string (e.g., "65.000 đ" -> 65000)
    String numericString =
        product['price']!.replaceAll('.', '').replaceAll(' đ', '');
    total += int.parse(numericString);
  }

  // Format the total as a price string
  String formattedTotal = total.toString();
  // Add thousand separators
  if (formattedTotal.length > 3) {
    String result = '';
    int counter = 0;
    for (int i = formattedTotal.length - 1; i >= 0; i--) {
      counter++;
      result = formattedTotal[i] + result;
      if (counter % 3 == 0 && i > 0) {
        result = '.' + result;
      }
    }
    formattedTotal = result;
  }
  return formattedTotal + ' đ';
}
