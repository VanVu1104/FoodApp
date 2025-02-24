import 'package:flutter/material.dart';

class DeliveryAddressWidget extends StatefulWidget {
  const DeliveryAddressWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<DeliveryAddressWidget> createState() => _DeliveryAddressWidgetState();
}

class _DeliveryAddressWidgetState extends State<DeliveryAddressWidget> {
  final deliveryAddress = '174/36 Phạm Phú Thứ, phường 11, Tân Bình, TP Hồ Chí Minh';
  bool isDelivery = true;
  bool isExpanded = false;

  // List of pickup addresses
  final List<String> pickupAddresses = [
    '32 Trường Sơn, Phường 2, Tân Bình, TP Hồ Chí Minh',
    '828 Sư Vạn Hạnh, phường 12, quận 10, TP Hồ Chí Minh',
    '32 Trường Sơn, Phường 2, Tân Bình, TP Hồ Chí Minh',
    '52 Ba Gia, Phường 7, Tân Bình, TP Hồ Chí Minh',
    '806 QL22, ấp Mỹ Hoà 3, Hóc Môn, Hồ Chí Minh',
  ];

  String selectedPickupAddress = '32 Trường Sơn, Phường 2, Tân Bình, TP Hồ Chí Minh';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Delivery Type Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Delivery Option
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isDelivery = true;
                        isExpanded = false;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.delivery_dining,
                          color: isDelivery ? Colors.red : Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Giao tận nơi',
                          style: TextStyle(
                            color: isDelivery ? Colors.red : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Pickup Option
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isDelivery = false;
                        isExpanded = false;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.store,
                          color: !isDelivery ? Colors.red : Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Đặt đến lấy',
                          style: TextStyle(
                            color: !isDelivery ? Colors.red : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Pickup Address Section with Dropdown
          if (isDelivery) ...[
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedPickupAddress,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.black,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  children: pickupAddresses.map((address) => InkWell(
                    onTap: () {
                      setState(() {
                        selectedPickupAddress = address;
                        isExpanded = false;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedPickupAddress == address
                            ? Colors.grey.shade100
                            : Colors.white,
                      ),
                      child: Text(
                        address,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )).toList(),
                ),
              ),
          ],
          const Divider(height: 1, thickness: 0.5),
          // Delivery Address Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {},
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      deliveryAddress,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.edit_location_alt,
                    color: Colors.amber,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}