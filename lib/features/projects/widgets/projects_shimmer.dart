import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProjectCardShimmer extends StatelessWidget {
  const ProjectCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6, // Show 6 shimmer cards
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        // Add slight delay for each card to create wave effect
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          curve: Curves.easeOutCubic,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _ShimmerProjectCard(index: index),
          ),
        );
      },
    );
  }
}

class _ShimmerProjectCard extends StatelessWidget {
  final int index;

  const _ShimmerProjectCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final random = Random(index); // Use index as seed for consistent randomness

    // Helper to generate random width within range
    double randomWidth(double min, double max) =>
        min + random.nextDouble() * (max - min);

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade50,
      period: Duration(milliseconds: 1500 + (index * 200)), // Staggered animation
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: User Info Header Shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Avatar shimmer with gradient effect
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey.shade200,
                            Colors.grey.shade300,
                            Colors.grey.shade200,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User name shimmer
                        Container(
                          height: 14,
                          width: randomWidth(80, 140),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Job title shimmer
                        Container(
                          height: 12,
                          width: randomWidth(60, 100),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Favorite button shimmer
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Section 2: Metadata Shimmer (Time, Views, Offers)
            Row(
              children: [
                _buildShimmerMetaInfo(randomWidth(15, 20)),
                const SizedBox(width: 16),
                _buildShimmerMetaInfo(randomWidth(15, 20)),
                const SizedBox(width: 16),
                _buildShimmerMetaInfo(randomWidth(15, 20)),
              ],
            ),
            const SizedBox(height: 16.0),

            // Section 3: Project Description Shimmer
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Multiple description lines with varying lengths
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: randomWidth(200, double.infinity),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: randomWidth(150, 280),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Divider shimmer
            Container(
              height: 2,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 16.0),

            // Button shimmer with rounded corners and gradient
            Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade200,
                    Colors.grey.shade300,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerMetaInfo(double iconSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon shimmer
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6.0),
        // Text shimmer
        Container(
          height: 10,
          width: Random().nextDouble() * 30 + 20, // Random width between 20-50
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}

// Alternative shimmer with wave animation
class WaveProjectCardShimmer extends StatefulWidget {
  const WaveProjectCardShimmer({super.key});

  @override
  State<WaveProjectCardShimmer> createState() => _WaveProjectCardShimmerState();
}

class _WaveProjectCardShimmerState extends State<WaveProjectCardShimmer>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
    _waveController.repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = (_waveAnimation.value - delay).clamp(0.0, 1.0);

            return Transform.translate(
              offset: Offset(0, sin(animationValue * pi * 2) * 2),
              child: Opacity(
                opacity: 0.3 + (animationValue * 0.7),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _ShimmerProjectCard(index: index),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Pulsing shimmer effect
class PulsingProjectCardShimmer extends StatelessWidget {
  const PulsingProjectCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 800 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.95 + (value * 0.05),
              child: Opacity(
                opacity: 0.4 + (value * 0.6),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _ShimmerProjectCard(index: index),
                ),
              ),
            );
          },
        );
      },
    );
  }
}