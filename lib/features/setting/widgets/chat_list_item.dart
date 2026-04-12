import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

import '../model/chats_model.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.chat,
    this.onTap,
  });

  final ChatsModel chat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = chat.receiver?.image?.trim() ?? '';
    final projectTitle = chat.projectTitle?.trim() ?? '';
    final unreadCount = chat.unreadCount ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFE9EEF5),
          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
          child: image.isEmpty
              ? const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF7D8A9A),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      chat.receiver?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
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
              ),
              if (projectTitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F7FB),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFD9E7F3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.work_outline_rounded,
                        size: 14,
                        color: Color(0xFF2D6A9F),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          projectTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF2D6A9F),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      chat.lastMessageSnippet ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF88878B),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: 22,
                        minHeight: 22,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0C7D81),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    )
        .paddingAll(12)
        .onTap(
          onTap ??
              () {
                CustomNavigator.push(
                  Routes.chat,
                  arguments: {
                    'conversationId': chat.id,
                    'project_id': chat.projectId,
                    'projectId': chat.projectId,
                    'freelancerId': chat.receiver?.id,
                    'freelancerName': chat.receiver?.name,
                    'freelancerJobTitle': chat.receiver?.jobTitle,
                  },
                );
              },
          borderRadius: BorderRadius.circular(12),
        )
        .setContainerToView(
          color: Colors.white,
          radius: 12,
        );
  }
}
