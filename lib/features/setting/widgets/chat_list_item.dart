import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

import '../model/chats_model.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.chat,
  });

  final ChatsModel chat;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            chat.receiver?.image??"",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chat.receiver?.name ?? '',
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
                chat.lastMessageSnippet ?? '',
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
          chat.since ?? '',
          style: const TextStyle(
            color: Color(0xFF88878B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).paddingAll(12).onTap((){
      CustomNavigator.push(
        Routes.chat,
        arguments: {
          'conversationId': chat.id,
          'freelancerId': chat.receiver?.id,
          'freelancerName': chat.receiver?.name,
          'freelancerJobTitle': chat.receiver?.jobTitle,
        },
      );
    },borderRadius: BorderRadius.circular(12)).setContainerToView(
     color: Colors.white,
      radius: 12,
    );
  }
}
