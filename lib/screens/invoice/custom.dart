import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  DashedBorderPainter({
    this.color = Colors.red,
    this.strokeWidth = 1.0,
    this.dashWidth = 10.0,
    this.dashSpace = 8.0,
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();

    // Create a rounded rectangle path
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    ));

    // Convert the path to a dashed path
    final Path dashedPath = dashPath(
      path,
      dashWidth: dashWidth,
      dashSpace: dashSpace,
    );

    // Draw the dashed path
    canvas.drawPath(dashedPath, paint);
  }

  Path dashPath(
    Path originalPath, {
    required double dashWidth,
    required double dashSpace,
  }) {
    final Path dashedPath = Path();
    for (final PathMetric pathMetric in originalPath.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;

      while (distance < pathMetric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (distance + length > pathMetric.length) {
          break;
        }
        final Path extractPath =
            pathMetric.extractPath(distance, distance + length);
        if (draw) {
          dashedPath.addPath(extractPath, Offset.zero);
        }
        distance += length;
        draw = !draw;
      }
    }
    return dashedPath;
  }

  double getPathLength(Path path) {
    final PathMetrics pathMetrics = path.computeMetrics();
    double totalLength = 0.0;

    for (PathMetric metric in pathMetrics) {
      totalLength += metric.length;
    }

    return totalLength;
  }

  Offset evalPath(Path path, double distance) {
    final PathMetrics pathMetrics = path.computeMetrics();
    Offset result = Offset.zero;

    for (PathMetric metric in pathMetrics) {
      if (distance <= metric.length) {
        final Tangent? tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          result = tangent.position;
        }
        break;
      }
      distance -= metric.length;
    }

    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
class OrderItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String imagePath;

  const OrderItemWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: Image.asset(
              imagePath,
              width: 36,
              height: 36,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.fastfood,
                color: Colors.amber,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '1×',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class OrderDetailsWidget extends StatelessWidget {
  const OrderDetailsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: Colors.red,
          strokeWidth: 2.0,
          dashWidth: 10.0,
          dashSpace: 8.0,
          radius: 12.0,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Color(0xFFFFE0E0).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Mã đơn', '26546233'),
              const SizedBox(height: 8),
              _buildDetailRow('Người nhận', 'ThyDo'),
              const SizedBox(height: 8),
              _buildDetailRow('Số điện thoại', '0373408741'),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Địa chỉ nhận hàng',
                '174/36 Phạm Phú Thứ, phường 11, Tân Bình, Hồ Chí Minh',
                multiLine: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool multiLine = false}) {
    return Row(
      crossAxisAlignment:
          multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
            maxLines: multiLine ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
