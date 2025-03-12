import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/models/cart.dart';
import 'package:demo_firebase/services/cart_service.dart';
import 'package:demo_firebase/widgets/custom_loading.dart';
import 'package:demo_firebase/widgets/order_product_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // This will be hardcoded for UI only
  final currencyFormatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Thông tin đặt hàng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant info section
            _buildRestaurantInfo(),

            // Delivery address section
            _buildDeliveryAddress(),

            // Order items section
            _buildOrderItemsSection(),

            // Order note section
            _buildOrderNoteSection(),

            // Payment info section - Part 1
            _buildPaymentInfoSection(),

            // Payment methods section
            _buildPaymentMethodsSection(),

            // Bottom total + order button
            _buildBottomOrderSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "C",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Restaurant details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "CRUNCH & DASH - Sư Vạn Hạnh",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "828 Sư Vạn Hạnh, Phường 12, Quận 10, Hồ Chí Minh",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.location_on,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Address details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "174/36 Phạm Phú Thứ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "174/36 Phạm Phú Thứ, phường 11, Tân Bình, Hồ Chí Minh",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Edit icon
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.amber,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Món ăn đã chọn",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Chức năng thêm món ăn
                },
                child: const Text(
                  "Thêm món",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Thêm StreamBuilder vào danh sách children của Column
        StreamBuilder<List<CartItem>>(
          stream: _cartService.getCartItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CustomLoading());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyCartMessage();
            }

            final cartItems = snapshot.data!;

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12.0),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return CartItemCard(
                  item: item,
                  onTap: () {
                    // TODO: Xử lý khi nhấn vào item
                  },
                );
              },
              separatorBuilder: (context, index) => Divider(
                color: Color(0xFFFFBFBF),
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrderNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ghi chú đơn hàng",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    "Ghi chú đặc biệt cho đơn hàng (vd: thời gian giao hàng mong muốn, yêu cầu lặp đặc biệt...)",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thông tin thanh toán",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tạm tính",
                style: TextStyle(fontSize: 15),
              ),
              Text(
                "130.000đ",
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Phí vận chuyển (5.2 km)",
                style: TextStyle(fontSize: 15),
              ),
              Text(
                "20.000đ",
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Chọn mã ưu đãi",
                style: TextStyle(fontSize: 15),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[500],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Thanh toán với điểm thưởng",
                style: TextStyle(fontSize: 15),
              ),
              Switch(
                value: false,
                onChanged: (value) {},
                activeColor: Colors.green,
              ),
            ],
          ),
          const Text(
            "Số dư điểm thưởng hiện tại của bạn là 500đ",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          const Text(
            "Phương thức thanh toán",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Payment method 1
          _buildPaymentMethodItem(
            icon: Icons.payments_outlined,
            color: Colors.green,
            name: "Thanh toán tiền mặt",
            isSelected: true,
          ),

          // Payment method 2
          _buildPaymentMethodItem(
            icon: Icons.account_balance_wallet,
            color: Colors.blue,
            name: "Zalopay",
            isSelected: false,
          ),

          // Payment method 3
          _buildPaymentMethodItem(
            icon: Icons.payment,
            color: Colors.red,
            name: "VNPAY",
            isSelected: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required Color color,
    required String name,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Radio(
            value: isSelected,
            groupValue: true,
            onChanged: (value) {},
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOrderSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Tổng thanh toán:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "130.000đ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Đặt món",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildEmptyCartMessage() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'Giỏ hàng của bạn đang trống',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
    ),
  );
}
