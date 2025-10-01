import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum ProjectStatus {
  completed,
  draft,
  rejected,
  canceled,
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
        _getStatusKey().tr(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 🔹 Helper: convert string -> enum
class ProjectStatusHelper {
  static ProjectStatus fromString(String? statusString) {
    if (statusString == null || statusString.isEmpty) {
      return ProjectStatus.draft;
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
      case 'ملغاة':
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
        return ProjectStatus.draft;
    }
  }
}
