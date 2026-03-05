import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/features/home/model/chat_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final bool isSent = message.isSent ?? false;
    final String text = (message.message ?? '').trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSent ? Styles.PRIMARY_COLOR : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSent ? Styles.PRIMARY_COLOR : const Color(0xFFD9DEE6),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            text.isEmpty ? '-' : text,
            style: TextStyle(
              color: isSent ? Colors.white : const Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if ((message.time ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              message.time!.trim(),
              style: TextStyle(
                color: isSent
                    ? Colors.white.withValues(alpha: 0.85)
                    : const Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
