import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/models/product.dart';
import 'package:demo_firebase/services/cart_service.dart';
import 'package:demo_firebase/services/order_service.dart';
import 'package:demo_firebase/services/product_service.dart';
import 'package:demo_firebase/utils/utils.dart';
import 'package:demo_firebase/widgets/order_history_detail.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isPaymentExpanded = true;
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> orderItems = [];

  late OrderService _orderService;
  final ProductService _productService = ProductService();
  @override
  void initState() {
    super.initState();
    final cartService = CartService();
    _orderService = OrderService(cartService);
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      // Use the OrderService to get order details
      final orderDetails = await _orderService.getOrderById(widget.orderId);
      print("OrderDetails load được là: ${orderDetails}");
      // Get pickup address from Firestore if pickUpAddressId exists
      if (orderDetails['pickUpAddressId'] != null &&
          orderDetails['pickUpAddressId'].isNotEmpty) {
        try {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('addresses')
              .where('addressId', isEqualTo: orderDetails['pickUpAddressId'])
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            // Extract address name from the document
            String pickUpAddress = querySnapshot.docs.first['addressName'] ??
                'Địa chỉ không xác định';

            // Update the orderDetails with the fetched address name
            orderDetails['pickUpAddress'] = pickUpAddress;
          } else {
            // Handle case where no matching address was found
            orderDetails['pickUpAddress'] = 'Địa chỉ không tìm thấy';
            print(
                'Không tìm thấy địa chỉ với ID: ${orderDetails['pickUpAddressId']}');
          }
        } catch (e) {
          orderDetails['pickUpAddress'] = 'Địa chỉ không xác định';
          print('Lỗi lấy địa chỉ: $e');
        }
      } else {
        // Default value if no pickUpAddressId is provided
        orderDetails['pickUpAddress'] = '';
      }
      List<dynamic> cartItems = orderDetails['listCartItem'] ?? [];
      List<Map<String, dynamic>> simplifiedOrderItems = [];

      for (var item in cartItems) {
        String productId = item['productId'].toString();

        // Get product details from service
        final product = await _productService.getProductByProductId(productId);

        if (product != null) {
          // Get the size information if available
          String sizeId = item['sizeId'] ?? '';
          String sizeName = 'Standard';

          // Find the matching size if it exists
          if (product.sizes != null && product.sizes.isNotEmpty) {
            final size = product.sizes.firstWhere(
              (s) => s.sizeId == sizeId,
              orElse: () =>
                  ProductSize(sizeId: '', sizeName: 'Standard', extraPrice: 0),
            );
            sizeName = size.sizeName;
          }

          simplifiedOrderItems.add({
            'productName': product.productName ?? 'Sản phẩm',
            'productImg': product.productImg,
            'sizeName': sizeName,
            'price': item['unitPrice'] ?? product.productPrice ?? 0,
            'quantity': item['quantity'] ?? 1,
          });
        }
      }
      setState(() {
        _orderDetails = orderDetails;
        orderItems = simplifiedOrderItems;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải đơn hàng. Vui lòng thử lại sau.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildOrderDetail(),
    );
  }

  Widget _buildOrderDetail() {
    // Extract needed data from order details
    final status = _orderDetails?['status'] ?? 'processing';
    final createdAt = _orderDetails?['createdAt'] as Timestamp?;
    final formattedDate = createdAt != null
        ? '${createdAt.toDate().day.toString().padLeft(2, '0')}/${createdAt.toDate().month.toString().padLeft(2, '0')}/${createdAt.toDate().year} | ${createdAt.toDate().hour.toString().padLeft(2, '0')}:${createdAt.toDate().minute.toString().padLeft(2, '0')}'
        : 'N/A';
    final totalPrice = _orderDetails?['totalPrice'] ?? 0.0;
    final paymentMethod = _orderDetails?['paymentMethod'] ?? 'cash';
    final deliveryFee = _orderDetails?['deliveryFee'] ?? 0.0;
    final deliveryAddress = _orderDetails?['deliveryAddressName'] ?? '';
    final pickUpAddress = _orderDetails?['pickUpAddress'] ?? '';
    final orderDiscount = _orderDetails?['orderDiscount'] ?? 0.0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            _buildStatusCard(status),

            const SizedBox(height: 24),

            // Restaurant Name (from pickup address or could be fetched elsewhere)
            Text(
              pickUpAddress.isNotEmpty ? pickUpAddress : 'CRUNCH & DASH',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            // Order Items
            OrderHistoryDetailCard(
              orderId: widget.orderId,
              items: orderItems,
            ),

            const SizedBox(height: 16),

            // Payment Details Section
            _buildPaymentDetails(
                totalPrice, deliveryFee, orderDiscount, paymentMethod),

            const SizedBox(height: 16),

            // Order Code and Date
            Row(
              children: [
                Text(
                  'Mã đơn: ${widget.orderId.substring(0, 8)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.copy_outlined, size: 16, color: Colors.grey[600]),
                const Spacer(),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Restaurant Info
            _buildRestaurantInfo(pickUpAddress),

            const SizedBox(height: 16),

            // Delivery Address
            _buildDeliveryAddressInfo(deliveryAddress),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    IconData statusIcon;
    String statusTitle;
    String statusMessage;
    Color statusColor;

    switch (status) {
      case 'completed':
        statusIcon = Icons.check_circle;
        statusTitle = 'Đơn hàng của bạn đã hoàn tất';
        statusMessage =
            'Chúc bạn ngon miệng! Đừng quên đánh giá giúp đỡ của hàng bạn nhé.';
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusIcon = Icons.cancel;
        statusTitle = 'Đơn hàng đã bị hủy';
        statusMessage = 'Rất tiếc đơn hàng của bạn đã bị hủy.';
        statusColor = Colors.red;
        break;
      case 'delivering':
        statusIcon = Icons.local_shipping;
        statusTitle = 'Đơn hàng đang được giao';
        statusMessage = 'Đơn hàng của bạn đang trên đường giao đến.';
        statusColor = Colors.blue;
        break;
      case 'preparing':
        statusIcon = Icons.restaurant;
        statusTitle = 'Đơn hàng đang được chuẩn bị';
        statusMessage = 'Nhà hàng đang chuẩn bị món ăn của bạn.';
        statusColor = Colors.orange;
        break;
      default:
        statusIcon = Icons.hourglass_bottom;
        statusTitle = 'Đơn hàng đang chờ xác nhận';
        statusMessage = 'Đơn hàng của bạn đang được xử lý.';
        statusColor = Colors.amber;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusMessage,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(statusIcon, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(num totalPrice, num deliveryFee,
      num orderDiscount, String paymentMethod) {
    // Calculate subtotal (before discounts)
    final subtotal = totalPrice + orderDiscount - deliveryFee;

    return Column(
      children: [
        // Header with arrow
        InkWell(
          onTap: () {
            setState(() {
              _isPaymentExpanded = !_isPaymentExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  'Chi tiết thanh toán',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isPaymentExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),
        const Divider(),

        // Expanded payment details
        if (_isPaymentExpanded) ...[
          // Temporary subtotal
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tạm tính',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  Utils().formatCurrency(subtotal),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Delivery fee
          if (deliveryFee > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Phí giao hàng',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    Utils().formatCurrency(deliveryFee),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Order discount if applicable
          if (orderDiscount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giảm giá',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '-${Utils().formatCurrency(orderDiscount)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),

          const Divider(),
        ],

        // Total amount (always visible)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: paymentMethod == 'cash'
                      ? Colors.green[100]
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  paymentMethod == 'cash' ? Icons.attach_money : Icons.payment,
                  color: paymentMethod == 'cash' ? Colors.green : Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                paymentMethod == 'cash'
                    ? 'Thanh toán tiền mặt'
                    : 'Thanh toán ZaloPay',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                Utils().formatCurrency(totalPrice),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo(String pickUpAddress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CRUNCH & DASH',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pickUpAddress.isNotEmpty
                      ? pickUpAddress
                      : 'Địa chỉ không xác định',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressInfo(String deliveryAddress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deliveryAddress.isNotEmpty
                      ? deliveryAddress
                      : 'Đơn lấy tại cửa hàng',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
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
