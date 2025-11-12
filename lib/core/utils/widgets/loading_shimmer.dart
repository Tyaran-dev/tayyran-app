// lib/core/utils/widgets/loading_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class LoadingShimmer {
  static Widget hotelCard() {
    return Card(
      elevation: 2,
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
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer(
              color: Colors.grey[300]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name and rating
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 20, color: Colors.white),
                      ),
                      Container(width: 60, height: 20, color: Colors.white),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Container(height: 16, width: 150, color: Colors.white),

                  const SizedBox(height: 8),

                  // Facilities
                  Row(
                    children: [
                      Container(height: 24, width: 60, color: Colors.white),
                      const SizedBox(width: 8),
                      Container(height: 24, width: 70, color: Colors.white),
                      const SizedBox(width: 8),
                      Container(height: 24, width: 80, color: Colors.white),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 12,
                              width: 80,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 20,
                              width: 100,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 12,
                              width: 60,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Container(height: 40, width: 120, color: Colors.white),
                    ],
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
