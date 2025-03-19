import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class DiscountScreen extends StatelessWidget {
  const DiscountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define promotional items
    final List<Map<String, dynamic>> promotionalItems = [
      {
        'imagePath': 'assets/1tang1.png',
        'subtitle': 'MỞ TIỆC TÂN NIÊN\nTẠI CRUNCH & DASH',
        'isHotSale': false,
      },
      {
        'imagePath': 'assets/25.png',
        'subtitle': 'Giảm 25% vào thứ 3\nhàng tuần',
        'isHotSale': false,
      },
      {
        'imagePath': 'assets/50.png',
        'subtitle': 'Giảm 50% cho đơn\nhàng thứ 2',
        'isHotSale': false,
      },
    ];

    // Check if the count is odd
    final bool isOddCount = promotionalItems.length % 2 != 0;

    return Scaffold(
      appBar: customAppBar(context, 'Ưu Đãi'),
      body: Column(
        children: [
          // Tab selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Ưu đãi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'E-Voucher',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Promotional cards grid
          Expanded(
            child: isOddCount
                ? _buildAdaptiveGrid(promotionalItems)
                : GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16),
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: promotionalItems
                        .map((item) => PromotionalCard(
                              imagePath: item['imagePath'],
                              subtitle: item['subtitle'],
                              isHotSale: item['isHotSale'] ?? false,
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveGrid(List<Map<String, dynamic>> items) {
    return CustomScrollView(
      slivers: [
        // Add padding using SliverPadding
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Container(
              height: 300, // Adjust height as needed
              margin: const EdgeInsets.only(bottom: 16),
              child: PromotionalCard(
                imagePath: items[0]['imagePath'],
                subtitle: items[0]['subtitle'],
                isHotSale: items[0]['isHotSale'] ?? false,
                isFullWidth: true,
              ),
            ),
          ),
        ),
        // Padding for the grid
        SliverPadding(
          padding: const EdgeInsets.all(16).copyWith(
              top: 0), // No top padding as it's handled by the margin above
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final itemIndex = index + 1; // Skip the first item
                if (itemIndex < items.length) {
                  return PromotionalCard(
                    imagePath: items[itemIndex]['imagePath'],
                    subtitle: items[itemIndex]['subtitle'],
                    isHotSale: items[itemIndex]['isHotSale'] ?? false,
                  );
                }
                return null;
              },
              childCount: items.length - 1,
            ),
          ),
        ),
      ],
    );
  }
}

class PromotionalCard extends StatelessWidget {
  final String imagePath;
  final String subtitle;
  final bool isHotSale;
  final bool isFullWidth;

  const PromotionalCard({
    super.key,
    required this.imagePath,
    required this.subtitle,
    this.isHotSale = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Main image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Center(
                    // Center the image
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                // Hot Sale tag (if applicable)
                if (isHotSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HOT SALE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Subtitle
          Expanded(
            flex: isFullWidth ? 1 : 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isFullWidth ? 20 : 16,
                  fontWeight: isFullWidth ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
