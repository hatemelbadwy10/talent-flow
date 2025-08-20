import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';

enum ProjectStatus {
  completed, // مكتملة
  draft, // مسودة
  rejected, // مرفوضة
  canceled, // ملغاه
  open, // مفتوحة
  inProgress, // قيد التنفيذ
  underReview, // قيد المراجعة
}

class StatusChip extends StatelessWidget {
  final ProjectStatus status;

  const StatusChip({super.key, required this.status});

  String _getStatusText() {
    switch (status) {
      case ProjectStatus.completed:
        return "مكتملة";
      case ProjectStatus.draft:
        return "مسودة";
      case ProjectStatus.rejected:
        return "مرفوضة";
      case ProjectStatus.canceled:
        return "ملغاة";
      case ProjectStatus.open:
        return "مفتوحة";
      case ProjectStatus.inProgress:
        return "قيد التنفيذ";
      case ProjectStatus.underReview:
        return "قيد المراجعة";
    }
  }

  Color _getBackgroundColor() {
    switch (status) {
      case ProjectStatus.completed:
        return const Color(0xFFDEFBE8); // Light Green (matching UI)
      case ProjectStatus.draft:
        return const Color(0xFFFEDF89); // Light Yellow (matching UI)
      case ProjectStatus.rejected:
        return const Color(0xFFFEE4E2); // Light Red
      case ProjectStatus.canceled:
        return const Color(0xFFF8F9FA); // Light Grey
      case ProjectStatus.open:
        return const Color(0xFFAED4D5); // Light Blue
      case ProjectStatus.inProgress:
        return const Color(0xFFEBF0FF); // Lighter Purple/Blue
      case ProjectStatus.underReview:
        return const Color(0xFFF4E8FE); // Light Purple
    }
  }

  // Helper method to get the correct text color
  Color _getTextColor() {
    switch (status) {
      case ProjectStatus.completed:
        return const Color(0xFF22C55E); // Green (matching UI)
      case ProjectStatus.draft:
        return const Color(0xFFF59E0B); // Orange/Yellow (matching UI)
      case ProjectStatus.rejected:
        return const Color(0xFFA82C29); // Dark Red
      case ProjectStatus.canceled:
        return const Color(0xFF6C757D); // Dark Grey
      case ProjectStatus.open:
        return const Color(0xFF1388B5); // Dark Blue
      case ProjectStatus.inProgress:
        return const Color(0xFF4C6EF5); // Dark Purple/Blue
      case ProjectStatus.underReview:
        return const Color(0xFF862E9C); // Dark Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12), // Matching UI roundness
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ProjectPortfolioCard extends StatelessWidget {
  final ProjectStatus status;
  final String title;
  final int likes;
  final int views;

  const ProjectPortfolioCard({
    super.key,
    required this.status,
    this.title = "موقع لإدارة مستشفى بداخلها عيادات",
    this.likes = 5,
    this.views = 103,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with overlay chip
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/images/my_projects.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback container with gradient to match the UI design
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF7DD3FC),
                            Color(0xFF0EA5E9),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff666568),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Bottom row with stats and status
                  Row(
                    children: [
                      // Stats on the left
                      Row(
                        children: [
                          _buildStatItem(
                              Icons.thumb_up_alt_outlined, likes.toString()),
                          _buildStatItem(
                              Icons.visibility_outlined, views.toString()),
                          SizedBox(width: 4.w),
                          StatusChip(status: status),
                        ],
                      ),
                      // Status chip on the right
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFF9CA3AF),
          size: 10,
        ),
        const SizedBox(width: 6),
        Text(
          count,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w200,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
