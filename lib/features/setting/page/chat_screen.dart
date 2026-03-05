import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/features/setting/bloc/chats_bloc.dart';
import 'package:talent_flow/features/setting/model/chats_model.dart';
import 'package:talent_flow/features/setting/widgets/chat_list_item.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatsModel> _filterChats(List<ChatsModel> allChats) {
    final query = _searchController.text.trim().toLowerCase();
    return allChats.where((chat) {
      final userName = (chat.receiver?.name ?? '').toLowerCase();
      final lastMessage = (chat.lastMessageSnippet ?? '').toLowerCase();
      return userName.contains(query) || lastMessage.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                        ).onTap(() {}, borderRadius: BorderRadius.circular(12)).setContainerToView(
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
                  child: BlocBuilder<ChatsBloc, AppState>(
                    builder: (context, state) {
                      if (state is Loading) {
                        return ListView.builder(
                          itemCount: 6,
                          itemBuilder: (_, __) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }

                      if (state is Error) {
                        return const Center(
                          child: Text("Failed to load chats"),
                        );
                      }

                      if (state is Done) {
                        final allChats = state.list?.cast<ChatsModel>() ?? [];
                        final filteredChats = _filterChats(allChats);

                        if (filteredChats.isEmpty) {
                          return const Center(
                            child: Text("No chats found"),
                          );
                        }

                        return ListAnimator(
                          addPadding: false,
                          customPadding: EdgeInsets.zero,
                          data: filteredChats
                              .map(
                                (chat) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ChatListItem(chat: chat),
                                ),
                              )
                              .toList(),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
