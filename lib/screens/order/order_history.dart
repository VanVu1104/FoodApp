// order_history_screen.dart
import 'package:demo_firebase/screens/invoice/invoice_screen.dart';
import 'package:demo_firebase/screens/login.dart';
import 'package:demo_firebase/screens/order/empty_history_screen.dart';
import 'package:demo_firebase/screens/order/order_details.dart';
import 'package:demo_firebase/services/cart_service.dart';
import 'package:demo_firebase/services/order_service.dart';
import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // If using Provider for DI

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late OrderService _orderService;
  List<Map<String, dynamic>> _displayOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final cartService = CartService();
    _orderService = OrderService(cartService);
    _checkAuthAndLoadOrders();
  }

  // Check if user is logged in before loading orders
  Future<void> _checkAuthAndLoadOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Vui lòng đăng nhập để xem lịch sử đơn hàng';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmptyOrderScreen()),
        );
        _isLoading = false;
      });
      return;
    }
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _orderService.getUserOrders();

      // Process orders asynchronously
      List<Map<String, dynamic>> formattedOrders = [];
      for (var order in orders) {
        // Await each formatted order
        Map<String, dynamic> formattedOrder =
            await _orderService.formatOrderForDisplay(order);
        formattedOrders.add(formattedOrder);
      }
      setState(() {
        _displayOrders = formattedOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải lịch sử đơn hàng: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Navigate to login screen
  void _navigateToLogin() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AuthScreen()));
  }

  // Handle review button press
  void _handleReviewPress(String orderId) {
    print('Navigate to review for order: $orderId');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InvoiceScreen(orderId: orderId)));
  }

  @override
  Widget build(BuildContext context) {
    bool shouldHideAppBar = _displayOrders.isEmpty || _errorMessage != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          shouldHideAppBar ? null : customAppBar(context, "Lịch sử đơn hàng"),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      // Special case for not logged in
      if (_errorMessage!.contains('đăng nhập')) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text('Đăng nhập', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      // General error
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_displayOrders.isEmpty) {
      return EmptyOrderScreen();
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        itemCount: _displayOrders.length,
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        itemBuilder: (context, index) {
          final order = _displayOrders[index];

          // Màu sắc cho trạng thái đơn hàng
          Color statusColor = const Color.fromARGB(255, 210, 243, 211);
          Color textColor = const Color.fromARGB(255, 39, 57, 40);
          if (order['status'] == 'Đơn hàng hủy') {
            statusColor = const Color.fromARGB(255, 245, 112, 125);
            textColor = const Color.fromARGB(255, 80, 22, 17);
          } else if (order['status'] == 'Chờ đánh giá') {
            statusColor = Colors.orange[100]!;
            textColor = Colors.orange;
          }

          return GestureDetector(
              onTap: () {
                // Navigate to order detail screen with the selected order ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderDetailScreen(orderId: order['orderId']),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 0),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade100, width: 1.2),
                  borderRadius: BorderRadius.circular(0),
                  color: Colors.white,
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thời gian đơn hàng
                        Text(
                          order['date'],
                          style: TextStyle(
                              fontSize: 15.5, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset('assets/storelist.png',
                                width: 80, height: 80),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    // Change this to Row instead of Text
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${order['quantity']} - ${order['price']}',
                                          style: TextStyle(
                                              fontSize: 15.5,
                                              color: Colors.black87),
                                          overflow: TextOverflow.visible,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Transform.translate(
                                offset: Offset(20, 40),
                                child: SizedBox(
                                  width: 90,
                                  height: 35,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _handleReviewPress(order['orderId']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                    ),
                                    child: Text(
                                      'Đánh giá',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Hiển thị trạng thái ở góc phải trên cùng
                    Align(
                      alignment: Alignment.topRight,
                      child: Transform.translate(
                        offset: Offset(20, -15),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            order['status'],
                            style: TextStyle(color: textColor, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }
}
