// lib/core/utils/widgets/loading_shimmer.dart
import 'package:flutter/material.dart';

class LoadingShimmer {
  static Widget text({
    required double width,
    required double height,
    double borderRadius = 4.0,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          // Base container
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          // Shimmer effect
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: ShimmerEffect(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget hotelCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const ShimmerEffect(),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel name
                text(width: 200, height: 20),
                const SizedBox(height: 8),

                // Location
                text(width: 150, height: 16),
                const SizedBox(height: 8),

                // Facilities
                text(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                text(width: 180, height: 16),
                const SizedBox(height: 12),

                // Price
                text(width: 100, height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget roomCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room name
            text(width: 200, height: 20),
            const SizedBox(height: 8),

            // Meal type
            text(width: 150, height: 16),
            const SizedBox(height: 4),

            // Inclusion
            text(width: 180, height: 16),
            const SizedBox(height: 4),

            // Refundable status
            text(width: 120, height: 16),
            const SizedBox(height: 12),

            // Price and button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(width: 80, height: 20),
                    const SizedBox(height: 4),
                    text(width: 60, height: 12),
                  ],
                ),
                text(width: 100, height: 36, borderRadius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget facilityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          text(width: 60, height: 14),
        ],
      ),
    );
  }

  static Widget image({
    double? width,
    double? height,
    double borderRadius = 0,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const ShimmerEffect(),
    );
  }

  static Widget circle({double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const ShimmerEffect(),
    );
  }

  static Widget button({double width = 100, double height = 40}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const ShimmerEffect(),
    );
  }
}

class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({super.key});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ShimmerPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ShimmerPainter extends CustomPainter {
  final double animationValue;

  ShimmerPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: [
        Colors.grey[300]!.withOpacity(0.6),
        Colors.grey[100]!,
        Colors.grey[300]!.withOpacity(0.6),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.topRight,
    );

    final rect = Rect.fromLTRB(
      -size.width,
      -size.height,
      size.width * 2,
      size.height,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    final x = size.width * animationValue;
    final path = Path()
      ..moveTo(x - size.width * 0.5, 0)
      ..lineTo(x, 0)
      ..lineTo(x + size.width * 0.5, size.height)
      ..lineTo(x - size.width * 0.5, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ShimmerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Alternative simpler version without animation:
class SimpleShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SimpleShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[300]!, Colors.grey[200]!, Colors.grey[300]!],
        ),
      ),
    );
  }
}

// Usage examples in your hotel details page:
class ShimmerUsageExamples extends StatelessWidget {
  const ShimmerUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text shimmers
        LoadingShimmer.text(width: 200, height: 24),
        const SizedBox(height: 8),
        LoadingShimmer.text(width: 150, height: 16),
        const SizedBox(height: 8),
        LoadingShimmer.text(width: double.infinity, height: 16),

        // Hotel card shimmer
        LoadingShimmer.hotelCard(),

        // Room card shimmer
        LoadingShimmer.roomCard(),

        // Facility chips
        Wrap(
          spacing: 8,
          children: List.generate(4, (index) => LoadingShimmer.facilityChip()),
        ),
      ],
    );
  }
}
