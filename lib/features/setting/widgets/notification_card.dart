import 'package:flutter/material.dart';
import 'package:talent_flow/features/setting/model/notification_model.dart';

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
          const SnackBar(content: Text("تم تعيين الإشعار كمقروء")),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: .25),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage:
              AssetImage('assets/images/profile_placeholder.png'),
            ),
            const SizedBox(width: 12.0),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title + Date row
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

                  /// Message
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

                  /// Extra data
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
    );
  }

  String _formatDate(DateTime date) {
    // 👉 You can localize this later with intl or easy_localization
    return "${date.year}/${date.month}/${date.day}";
  }
}
