import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/features/setting/model/notification_model.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notificationModel});
  final NotificationModel notificationModel;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notificationModel.id ?? UniqueKey()),
      direction: DismissDirection.endToStart, // swipe left to right (RTL)
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.green.shade400,
        child: const Icon(Icons.mark_email_read, color: Colors.white),
      ),
      onDismissed: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("notification_marked_as_read".tr())),
        );
      },
      child: InkWell(
        onTap: () => _handleTap(),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: .25),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationTypeAvatar(type: notificationModel.data?.type),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notificationModel.title != null ||
                        notificationModel.date != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (notificationModel.title != null &&
                              notificationModel.title!.isNotEmpty)
                            Flexible(
                              child: Text(
                                notificationModel.title!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (notificationModel.date != null)
                            Text(
                              _formatDate(notificationModel.date!),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 6.0),
                    if (notificationModel.message != null &&
                        notificationModel.message!.isNotEmpty)
                      Text(
                        notificationModel.message!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    const SizedBox(height: 6.0),
                    if (notificationModel.data?.extra != null &&
                        notificationModel.data!.extra!.isNotEmpty)
                      Text(
                        notificationModel.data!.extra!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    final data = notificationModel.data;
    final type = data?.type?.trim().toLowerCase();
    final targetId = data?.id;

    if (targetId == null || type == null || type.isEmpty) {
      return;
    }

    if (type == 'project' || type == 'projects') {
      CustomNavigator.push(
        Routes.singleProjectDetails,
        arguments: {'id': targetId},
      );
      return;
    }

    if (type == 'contract' || type == 'contracts') {
      CustomNavigator.push(Routes.contractDetails, arguments: targetId);
      return;
    }

    if (type == 'profile') {
      CustomNavigator.push(
        Routes.entrepreneur,
        arguments: {'entrepreneurId': targetId},
      );
      return;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}/${date.month}/${date.day}";
  }
}

class _NotificationTypeAvatar extends StatelessWidget {
  const _NotificationTypeAvatar({required this.type});

  final String? type;

  @override
  Widget build(BuildContext context) {
    final normalized = type?.trim().toLowerCase() ?? '';
    final config = _configFor(normalized);

    return CircleAvatar(
      radius: 24,
      backgroundColor: config.backgroundColor,
      child: Icon(
        config.icon,
        color: config.iconColor,
        size: 24,
      ),
    );
  }

  _NotificationTypeConfig _configFor(String type) {
    switch (type) {
      case 'project':
      case 'projects':
        return const _NotificationTypeConfig(
          icon: Icons.work_outline_rounded,
          backgroundColor: Color(0xFFE8F4FD),
          iconColor: Color(0xFF1E88E5),
        );
      case 'contract':
      case 'contracts':
        return const _NotificationTypeConfig(
          icon: Icons.description_outlined,
          backgroundColor: Color(0xFFEAF7EE),
          iconColor: Color(0xFF2E7D32),
        );
      case 'profile':
        return const _NotificationTypeConfig(
          icon: Icons.person_outline_rounded,
          backgroundColor: Color(0xFFF3E8FF),
          iconColor: Color(0xFF7B1FA2),
        );
      default:
        return const _NotificationTypeConfig(
          icon: Icons.notifications_none_rounded,
          backgroundColor: Color(0xFFF1F3F4),
          iconColor: Color(0xFF5F6368),
        );
    }
  }
}

class _NotificationTypeConfig {
  const _NotificationTypeConfig({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}
