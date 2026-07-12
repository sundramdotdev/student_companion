import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer-based skeleton card for loading states.
class SkeletonCard extends StatelessWidget {
  final double height;
  final double? width;

  const SkeletonCard({super.key, this.height = 100, this.width});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
      highlightColor: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a row of stat cards.
class SkeletonStatRow extends StatelessWidget {
  const SkeletonStatRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: SkeletonCard(height: 100)),
        SizedBox(width: 12),
        Expanded(child: SkeletonCard(height: 100)),
      ],
    );
  }
}

/// Shimmer skeleton for a list of items.
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonList({super.key, this.itemCount = 3, this.itemHeight = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonCard(height: itemHeight),
        ),
      ),
    );
  }
}
