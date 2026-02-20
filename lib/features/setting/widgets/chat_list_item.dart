import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/extensions.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.userName,
    required this.lastMessage,
    required this.timeLabel,
    required this.imageUrl,
  });

  final String userName;
  final String lastMessage;
  final String timeLabel;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF88878B),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          timeLabel,
          style: const TextStyle(
            color: Color(0xFF88878B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).paddingAll(12).onTap((){},borderRadius: BorderRadius.circular(12)).setContainerToView(
     color: Colors.white,
      radius: 12,
    );
  }
}
