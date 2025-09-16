import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:talent_flow/features/projects/model/my_projects_model.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../navigation/routes.dart';

enum ProjectStatus {
  completed,
  draft,
  rejected,
  canceled, // This will handle both "Cancelled" and "Closed"
  open,
  inProgress,
  underReview,
}

class StatusChip extends StatelessWidget {
  final ProjectStatus status;

  const StatusChip({super.key, required this.status});

  String _getStatusKey() {
    switch (status) {
      case ProjectStatus.completed:
        return "project_status.completed";
      case ProjectStatus.draft:
        return "project_status.draft";
      case ProjectStatus.rejected:
        return "project_status.rejected";
      case ProjectStatus.canceled:
        return "project_status.canceled";
      case ProjectStatus.open:
        return "project_status.open";
      case ProjectStatus.inProgress:
        return "project_status.in_progress";
      case ProjectStatus.underReview:
        return "project_status.under_review";
    }
  }

  Color _getBackgroundColor() {
    switch (status) {
      case ProjectStatus.completed:
        return const Color(0xFFDEFBE8);
      case ProjectStatus.draft:
        return const Color(0xFFFEDF89);
      case ProjectStatus.rejected:
        return const Color(0xFFFEE4E2);
      case ProjectStatus.canceled:
        return const Color(0xFFF8F9FA);
      case ProjectStatus.open:
        return const Color(0xFFAED4D5);
      case ProjectStatus.inProgress:
        return const Color(0xFFEBF0FF);
      case ProjectStatus.underReview:
        return const Color(0xFFF4E8FE);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case ProjectStatus.completed:
        return const Color(0xFF22C55E);
      case ProjectStatus.draft:
        return const Color(0xFFF59E0B);
      case ProjectStatus.rejected:
        return const Color(0xFFA82C29);
      case ProjectStatus.canceled:
        return const Color(0xFF6C757D);
      case ProjectStatus.open:
        return const Color(0xFF1388B5);
      case ProjectStatus.inProgress:
        return const Color(0xFF4C6EF5);
      case ProjectStatus.underReview:
        return const Color(0xFF862E9C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusKey().tr(), // 🔥 translated text
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// 🔹 Helper class to convert string status to enum
class ProjectStatusHelper {
  static ProjectStatus fromString(String? statusString) {
    if (statusString == null || statusString.isEmpty) {
      return ProjectStatus.draft; // default status
    }

    switch (statusString.toLowerCase().trim()) {
      case 'completed':
      case 'مكتمل':
        return ProjectStatus.completed;
      case 'draft':
      case 'مسودة':
        return ProjectStatus.draft;
      case 'rejected':
      case 'مرفوض':
        return ProjectStatus.rejected;
      case 'canceled':
      case 'cancelled':
      case 'ملغي':
        return ProjectStatus.canceled;
      case 'open':
      case 'مفتوحة':
        return ProjectStatus.open;
      case 'in_progress':
      case 'inprogress':
      case 'in progress':
      case 'قيد التنفيذ':
        return ProjectStatus.inProgress;
      case 'under_review':
      case 'underreview':
      case 'under review':
      case 'قيد المراجعة':
        return ProjectStatus.underReview;
      default:
        return ProjectStatus.draft; // fallback to draft for unknown statuses
    }
  }

  // 🔹 Optional: Convert enum back to string (useful for API calls)
  // static String toString(ProjectStatus status) {
  //   switch (status) {
  //     case ProjectStatus.completed:
  //       return 'completed';
  //     case ProjectStatus.draft:
  //       return 'draft';
  //     case ProjectStatus.rejected:
  //       return 'rejected';
  //     case ProjectStatus.canceled:
  //       return 'canceled';
  //     case ProjectStatus.open:
  //       return 'open';
  //     case ProjectStatus.inProgress:
  //       return 'in_progress';
  //     case ProjectStatus.underReview:
  //       return 'under_review';
  //   }
  // }
}

class ProjectPortfolioCard extends StatelessWidget {
  final MyProjectsModel projectsModel;

  const ProjectPortfolioCard({
    super.key,
    required this.projectsModel,
  });

  @override
  Widget build(BuildContext context) {
    log("projectsModel.status ${projectsModel.status}");
    // 🔹 Convert string status from model to enum
    final ProjectStatus status = ProjectStatusHelper.fromString(projectsModel.status);

    return Container(
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
      child: GestureDetector(
        onTap: () {
          CustomNavigator.push(
              Routes.singleProjectDetails, arguments: {"id": projectsModel.id});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                width: double.infinity,
                height: 120, // Added fixed height for consistency
                child: Image.network(
                  projectsModel.specialization?.image ?? "",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
                        child: Icon(Icons.image, color: Colors.white, size: 40),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectsModel.title ?? "project_portfolio.default_title".tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff666568),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    projectsModel.specialization?.name ?? "project_portfolio.default_specialization".tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff666568),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatItem(Icons.thumb_up_alt_outlined, (projectsModel.proposalsCount ?? 0).toString()),
                      const SizedBox(width: 8),
                      _buildStatItem(Icons.visibility_outlined, (projectsModel.views ?? 0).toString()),
                      const Spacer(), // Push status chip to the right
                      StatusChip(status: status), // 🔹 Use converted status
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
        Icon(icon, color: const Color(0xFF9CA3AF), size: 10),
        const SizedBox(width: 4),
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