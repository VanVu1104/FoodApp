import 'package:demo_firebase/screens/cart/cart_screen.dart';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Màu nền của header
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20, // Tránh status bar
        bottom: 10, // Khoảng cách dưới
        left: 10,
        right: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Image.asset(
            'assets/logo3.png',
            width: 200,
            fit: BoxFit.fitWidth,
          ),
          // Search and Cart Icons
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, size: 32, color: Colors.red),
                onPressed: () {
                  // Xử lý khi bấm tìm kiếm
                },
              ),
              Stack(
                children: [
                  IconButton(
                      icon: Icon(Icons.shopping_cart,
                          size: 32, color: Colors.red),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartScreen()),
                        );
                      }),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '0', // Số lượng giỏ hàng
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
