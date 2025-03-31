import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/coupon.dart';
import '../services/discount_service.dart';

class DiscountScreen extends StatefulWidget {
  final double? subtotal;
  final double? deliveryFee;
  final bool? isDelivery;
  final Coupon? initialOrderCoupon;
  final Coupon? initialShippingCoupon;

  const DiscountScreen({
    super.key,
    this.subtotal,
    this.deliveryFee,
    this.isDelivery,
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
    // Only set the shipping coupon if delivery is enabled
    selectedShippingCoupon =
        widget.isDelivery == false ? null : widget.initialShippingCoupon;
    initial();
  }

  Future<void> initial() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      List<Coupon> fetchedCoupons =
          await _discountService.getCouponsByUserId(userId);

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
        // Only allow selecting shipping coupon if delivery is enabled
        if (widget.isDelivery == true) {
          selectedShippingCoupon =
              (selectedShippingCoupon == coupon) ? null : coupon;
        }
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
                    final fee = widget.subtotal;

                    // Check if coupon is valid based on the type and delivery status
                    bool isShippingCouponDisabled =
                        coupon.type == CouponType.shipping &&
                            widget.isDelivery == false;

                    bool isValid = fee != null &&
                        _discountService.isValid(coupon.expiredDate, fee,
                            coupon.minPurchaseAmount) &&
                        !isShippingCouponDisabled;

                    bool isSelected = (coupon.type == CouponType.order &&
                            coupon.couponId == selectedOrderCoupon?.couponId) ||
                        (coupon.type == CouponType.shipping &&
                            coupon.couponId ==
                                selectedShippingCoupon?.couponId);

                    return Card(
                      color: isSelected
                          ? Colors.orangeAccent
                          : (isValid ? Colors.white : Colors.grey.shade300),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isShippingCouponDisabled ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giảm ${coupon.isPercentage ? "${coupon.discountValue}%" : "${coupon.discountValue}đ"}'
                              '${coupon.minPurchaseAmount != null ? " (Tối thiểu: ${coupon.minPurchaseAmount}đ)" : ""}',
                              style: TextStyle(
                                color: isShippingCouponDisabled
                                    ? Colors.grey
                                    : Colors.green,
                              ),
                            ),
                            if (isShippingCouponDisabled)
                              Text(
                                "Không khả dụng khi tự đến lấy",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            if (coupon.type == CouponType.shipping &&
                                widget.isDelivery == true)
                              Text(
                                "Phiếu giảm giá vận chuyển",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Icon(Icons.check,
                            color:
                                isSelected ? Colors.white : Colors.transparent),
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
              // Only return shipping coupon if delivery is enabled
              'shippingCoupon':
                  widget.isDelivery == true ? selectedShippingCoupon : null,
            });
          },
          child: Text('Xác nhận'),
        ),
      ),
    );
  }
}
