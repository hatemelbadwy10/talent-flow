import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/features/setting/widgets/chat_list_item.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<_ChatUiModel> _allChats = const [
    _ChatUiModel(
      userNameKey: 'chat_screen.user_ahmed',
      messageKey: 'chat_screen.msg_contract',
      timeKey: 'chat_screen.time_2_days',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
    ),
    _ChatUiModel(
      userNameKey: 'chat_screen.user_maryam',
      messageKey: 'chat_screen.msg_files',
      timeKey: 'chat_screen.time_yesterday',
      imageUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    ),
    _ChatUiModel(
      userNameKey: 'chat_screen.user_khaled',
      messageKey: 'chat_screen.msg_thanks',
      timeKey: 'chat_screen.time_1_hour',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
    ),
    _ChatUiModel(
      userNameKey: 'chat_screen.user_nora',
      messageKey: 'chat_screen.msg_meeting',
      timeKey: 'chat_screen.time_5_minutes',
      imageUrl:
          'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=200&q=80',
    ),
    _ChatUiModel(
      userNameKey: 'chat_screen.user_omar',
      messageKey: 'chat_screen.msg_update',
      timeKey: 'chat_screen.time_now',
      imageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredChats = _allChats.where((chat) {
      final userName = chat.userNameKey.tr().toLowerCase();
      final lastMessage = chat.messageKey.tr().toLowerCase();
      return userName.contains(query) || lastMessage.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => CustomNavigator.pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE7E7EC)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'chat_screen.title'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        sufAssetIcon: 'assets/icons/search.svg',
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        hint: 'chat_screen.search_hint'.tr(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: const Icon(
                        Icons.sort_rounded,
                        color: Colors.black87,
                      ).onTap((){},borderRadius: BorderRadius.circular(12)).setContainerToView(
                        width: 48,
                      height: 48,
                                                color: const Color(0xFFF2F4FA),
                        radius: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListAnimator(
                  addPadding: false,
                  customPadding: EdgeInsets.zero,
                  data: filteredChats
                      .map(
                        (chat) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ChatListItem(
                            userName: chat.userNameKey.tr(),
                            lastMessage: chat.messageKey.tr(),
                            timeLabel: chat.timeKey.tr(),
                            imageUrl: chat.imageUrl,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatUiModel {
  const _ChatUiModel({
    required this.userNameKey,
    required this.messageKey,
    required this.timeKey,
    required this.imageUrl,
  });

  final String userNameKey;
  final String messageKey;
  final String timeKey;
  final String imageUrl;
}
