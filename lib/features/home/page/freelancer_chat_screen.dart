import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/svg_images.dart';
import 'package:talent_flow/components/custom_images.dart';
import 'package:talent_flow/features/home/bloc/freelancer_chat_bloc.dart';
import 'package:talent_flow/features/home/model/chat_model.dart';
import 'package:talent_flow/features/home/widgets/chat_bubble.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class FreelancerChatScreen extends StatefulWidget {
  const FreelancerChatScreen({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  @override
  State<FreelancerChatScreen> createState() => _FreelancerChatScreenState();
}

class _FreelancerChatScreenState extends State<FreelancerChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    final String body = _messageController.text.trim();
    if (body.isEmpty) {
      return;
    }

    context.read<FreelancerChatBloc>().add(
          SendMessage(
            arguments: {
              'conversationId':
                  widget.arguments?['conversationId'] ?? widget.arguments?['freelancerId'],
              'body': body,
            },
          ),
        );
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fallbackFreelancerName =
        (widget.arguments?['freelancerName'] as String?)?.trim();
    final fallbackFreelancerJobTitle =
        (widget.arguments?['freelancerJobTitle'] as String?)?.trim();
    final freelancerId = widget.arguments?['freelancerId'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD9DEE6)),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => CustomNavigator.pop(),
              ),
            ),
          ),
        ),
        titleSpacing: 0,
        title: BlocBuilder<FreelancerChatBloc, AppState>(
          builder: (context, state) {
            String headerName = fallbackFreelancerName?.isNotEmpty == true
                ? fallbackFreelancerName!
                : 'Freelancer';
            String headerJob = fallbackFreelancerJobTitle?.isNotEmpty == true
                ? fallbackFreelancerJobTitle!
                : 'Freelancer';

            if (state is Done && state.data is ChatModel) {
              final model = state.data as ChatModel;
              final receiver = model.receiver;
              if ((receiver?.name ?? '').trim().isNotEmpty) {
                headerName = receiver!.name!.trim();
              }
              if ((receiver?.jobTitle ?? '').trim().isNotEmpty) {
                headerJob = receiver!.jobTitle!.trim();
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  headerJob,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              CustomNavigator.push(
                Routes.createContract,
                arguments: {'freelancerId': freelancerId},
              );
            },
            child: const Text(
              'Create Contract',
              style: TextStyle(
                color: Styles.PRIMARY_COLOR,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<FreelancerChatBloc, AppState>(
                builder: (context, state) {
                  if (state is Loading || state is Start) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Styles.PRIMARY_COLOR,
                      ),
                    );
                  }

                  if (state is Error) {
                    return const Center(
                      child: Text('Failed to load conversation'),
                    );
                  }

                  if (state is Empty) {
                    return const Center(
                      child: Text('No conversation selected'),
                    );
                  }

                  if (state is Done && state.data is ChatModel) {
                    final chat = state.data as ChatModel;
                    final messages = chat.messages;

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text('No messages yet'),
                      );
                    }

                    return ListView.separated(
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        final isSent = message.isSent ?? false;
                        return Align(
                          alignment: isSent
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            child: MessageBubble(message: message),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: const Color(0xFFD9DEE6)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a message',
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Styles.PRIMARY_COLOR.withValues(alpha: 0.08),
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: customImageIconSVG(
                        imageName: SvgImages.send,
                        color: Styles.PRIMARY_COLOR,
                        width: 20,
                        height: 20,
                      ),
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
}
