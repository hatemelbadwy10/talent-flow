import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:talent_flow/features/setting/bloc/chats_bloc.dart';
import 'package:talent_flow/features/setting/model/chats_model.dart';
import 'package:talent_flow/features/setting/widgets/chat_list_item.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    final chatsBloc = context.read<ChatsBloc>();
    context.read<UserBloc>().add(
          const UserUnreadCountsSynced(messages: 0),
        );
    Future.microtask(() {
      chatsBloc.add(const ChatProjectOptionsRequested());
      chatsBloc.add(const ChatsRequested());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openChat(ChatsModel chat) async {
    final conversationId = chat.id;
    if (conversationId != null) {
      context.read<ChatsBloc>().add(ConversationMarkedRead(conversationId));
    }

    final arguments = {
      'conversationId': chat.id,
      'project_id': chat.projectId,
      'projectId': chat.projectId,
      'contractId': chat.contractId,
      'hasContract': chat.hasContract == true,
      'freelancerId': chat.receiver?.id,
      'freelancerName': chat.receiver?.name,
      'freelancerJobTitle': chat.receiver?.jobTitle,
    };
    log(
      '[ChatScreen] opening Routes.chat from chat list | $arguments',
      name: 'ChatScreen',
    );

    await CustomNavigator.push(
      Routes.chat,
      arguments: arguments,
    );
    if (!mounted) return;
    context.read<ChatsBloc>().add(
          ChatsRequested(projectId: _selectedProjectId),
        );
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
              BlocBuilder<ChatsBloc, ChatsState>(
                buildWhen: (previous, current) => true,
                builder: (context, state) {
                  final projectOptions = state.projectOptions;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE7E7EC)),
                    ),
                    child: DropdownButton<int?>(
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      value: _selectedProjectId,
                      hint: Text('chat_screen.filter_by_project'.tr()),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('chat_screen.all_projects'.tr()),
                        ),
                        ...projectOptions.entries.map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectId = value;
                        });
                        context.read<ChatsBloc>().add(
                              ChatsRequested(projectId: value),
                            );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Expanded(
                child: BlocBuilder<ChatsBloc, ChatsState>(
                  builder: (context, state) {
                    if (state is ChatsLoading) {
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

                    if (state is ChatsFailed && state.chats.isEmpty) {
                      return Center(
                        child: Text("failed_to_load_chats".tr()),
                      );
                    }

                    if (state is ChatsLoaded ||
                        state is ChatsFailed && state.chats.isNotEmpty) {
                      final allChats = state.chats;

                      if (allChats.isEmpty) {
                        return Center(
                          child: Text("no_chats_found".tr()),
                        );
                      }

                      return ListAnimator(
                        addPadding: false,
                        customPadding: EdgeInsets.zero,
                        data: allChats
                            .map(
                              (chat) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ChatListItem(
                                  chat: chat,
                                  onTap: () => _openChat(chat),
                                ),
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
