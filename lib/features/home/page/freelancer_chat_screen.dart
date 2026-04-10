import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/svg_images.dart';
import 'package:talent_flow/components/custom_images.dart';
import 'package:talent_flow/data/config/di.dart';
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
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;

  int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  void _sendMessage() {
    final String body = _messageController.text.trim();
    if (body.isEmpty) {
      return;
    }

    context.read<FreelancerChatBloc>().add(
          SendMessage(
            arguments: {
              'conversationId': widget.arguments?['conversationId'] ??
                  widget.arguments?['freelancerId'],
              'body': body,
            },
          ),
        );
    _messageController.clear();
  }

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onComposerChanged);
  }

  void _onComposerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecordingAndSend();
      return;
    }
    await _startRecording();
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _showSnackBar('chat_screen.microphone_permission_denied'.tr());
        return;
      }

      final directory = await getTemporaryDirectory();
      final filePath = path.join(
        directory.path,
        'voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isRecording = true;
      });
    } catch (_) {
      _showSnackBar('chat_screen.voice_message_failed'.tr());
    }
  }

  Future<void> _stopRecordingAndSend() async {
    try {
      final filePath = await _audioRecorder.stop();
      if (!mounted) {
        return;
      }

      setState(() {
        _isRecording = false;
      });

      if (filePath == null || filePath.trim().isEmpty) {
        return;
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        _showSnackBar('chat_screen.voice_message_failed'.tr());
        return;
      }

      context.read<FreelancerChatBloc>().add(
            SendMessage(
              arguments: {
                'conversationId': widget.arguments?['conversationId'] ??
                    widget.arguments?['freelancerId'],
                'filePath': filePath,
              },
            ),
          );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRecording = false;
      });
      _showSnackBar('chat_screen.voice_message_failed'.tr());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_onComposerChanged);
    _messageController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fallbackFreelancerName =
        (widget.arguments?['freelancerName'] as String?)?.trim();
    final fallbackFreelancerJobTitle =
        (widget.arguments?['freelancerJobTitle'] as String?)?.trim();
    final freelancerId = widget.arguments?['freelancerId'];
    final fallbackProjectId = _parseInt(
        widget.arguments?['projectId'] ?? widget.arguments?['project_id']);
    final isFreelancer =
        sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false;

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
        actions: isFreelancer
            ? const []
            : [
                BlocBuilder<FreelancerChatBloc, AppState>(
                  builder: (context, state) {
                    final currentProjectId =
                        state is Done && state.data is ChatModel
                            ? (state.data as ChatModel).projectId ??
                                fallbackProjectId
                            : fallbackProjectId;

                    return TextButton(
                      onPressed: () {
                        CustomNavigator.push(
                          Routes.createContract,
                          arguments: {
                            'freelancerId': freelancerId,
                            'conversationId':
                                widget.arguments?['conversationId'],
                            if (currentProjectId != null)
                              'projectId': currentProjectId,
                          },
                        );
                      },
                      child: Text(
                        'chat_screen.create_contract'.tr(),
                        style: const TextStyle(
                          color: Styles.PRIMARY_COLOR,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
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
                    return Center(
                      child: Text('chat_screen.load_failed'.tr()),
                    );
                  }

                  if (state is Empty) {
                    return Center(
                      child: Text('chat_screen.no_conversation'.tr()),
                    );
                  }

                  if (state is Done && state.data is ChatModel) {
                    final chat = state.data as ChatModel;
                    final messages = chat.messages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Text('chat_screen.no_messages'.tr()),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isRecording)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC2626),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'chat_screen.recording'.tr(),
                              style: const TextStyle(
                                color: Color(0xFF991B1B),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
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
                            enabled: !_isRecording,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'chat_screen.type_message'.tr(),
                              hintStyle: const TextStyle(
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
                          color: _isRecording
                              ? const Color(0xFFFEE2E2)
                              : Styles.PRIMARY_COLOR.withValues(alpha: 0.08),
                        ),
                        child: IconButton(
                          onPressed: _isRecording
                              ? _toggleRecording
                              : (_messageController.text.trim().isNotEmpty
                                  ? _sendMessage
                                  : _toggleRecording),
                          icon: _isRecording
                              ? const Icon(
                                  Icons.stop_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 22,
                                )
                              : _messageController.text.trim().isNotEmpty
                                  ? customImageIconSVG(
                                      imageName: SvgImages.send,
                                      color: Styles.PRIMARY_COLOR,
                                      width: 20,
                                      height: 20,
                                    )
                                  : const Icon(
                                      Icons.mic_rounded,
                                      color: Styles.PRIMARY_COLOR,
                                      size: 22,
                                    ),
                        ),
                      ),
                    ],
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
