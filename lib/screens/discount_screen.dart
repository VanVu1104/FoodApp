import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../models/coupon.dart';
import '../services/discount_service.dart';

class DiscountScreen extends StatefulWidget {
  final double? subtotal;
  final double? deliveryFee;
  final Coupon? initialOrderCoupon;
  final Coupon? initialShippingCoupon;

  const DiscountScreen({
    super.key,
    this.subtotal,
    this.deliveryFee,
    this.initialOrderCoupon,
    this.initialShippingCoupon,
  });

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  final _discountService = DiscountService();
  List<Coupon> coupons = [];
  bool isLoading = true;
  Coupon? selectedOrderCoupon;
  Coupon? selectedShippingCoupon;

  @override
  void initState() {
    super.initState();
    selectedOrderCoupon = widget.initialOrderCoupon;
    selectedShippingCoupon = widget.initialShippingCoupon;
    initial();
  }

  Future<void> initial() async {
    try {
      String userId = 'userId';
      List<Coupon> fetchedCoupons = await _discountService.getCouponsByUserId(userId);

      setState(() {
        coupons = fetchedCoupons;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      }
    }
  }

  void selectCoupon(Coupon coupon) {
    setState(() {
      if (coupon.type == CouponType.order) {
        selectedOrderCoupon = (selectedOrderCoupon == coupon) ? null : coupon;
      } else if (coupon.type == CouponType.shipping) {
        selectedShippingCoupon = (selectedShippingCoupon == coupon) ? null : coupon;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Ưu Đãi'),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : coupons.isEmpty
          ? Center(child: Text('Không có phiếu giảm giá nào'))
          : ListView.builder(
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          final fee = coupon.type == CouponType.order ? widget.subtotal : widget.deliveryFee;
          bool isValid = fee != null && _discountService.isValid(coupon.expiredDate, fee, coupon.minPurchaseAmount);

          bool isSelected = (coupon.type == CouponType.order && coupon.couponId == selectedOrderCoupon?.couponId) ||
              (coupon.type == CouponType.shipping && coupon.couponId == selectedShippingCoupon?.couponId);

          return Card(
            color: isSelected ? Colors.orangeAccent : (isValid ? Colors.white : Colors.grey.shade300),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Image.network(
                coupon.couponImageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                coupon.couponName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Giảm ${coupon.isPercentage ? "${coupon.discountValue}%" : "${coupon.discountValue}đ"}'
                    '${coupon.minPurchaseAmount != null ? " (Tối thiểu: ${coupon.minPurchaseAmount}đ)" : ""}',
                style: TextStyle(color: Colors.green),
              ),
              trailing: Icon(Icons.check, color: isSelected ? Colors.white : Colors.transparent),
              onTap: () {
                if (isValid) {
                  selectCoupon(coupon);
                }
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'orderCoupon': selectedOrderCoupon,
              'shippingCoupon': selectedShippingCoupon,
            });
          },
          child: Text('Xác nhận'),
        ),
      ),
    );
  }
}
