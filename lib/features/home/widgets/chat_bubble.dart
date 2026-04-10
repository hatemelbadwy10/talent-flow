import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/features/home/model/chat_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSent ?? false;
    final text = (message.message ?? '').trim();
    final isVoiceMessage = _isVoiceMessage(message, text);

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
          if (isVoiceMessage)
            _VoiceMessageContent(
              messageUrl: text,
              isSent: isSent,
            )
          else
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

bool _isVoiceMessage(Message message, String text) {
  final type = (message.messageType ?? '').toLowerCase();
  if (type.contains('voice') || type.contains('audio')) {
    return true;
  }

  final uri = Uri.tryParse(text);
  final source = uri?.path.toLowerCase() ?? text.toLowerCase();
  final isConversationRecording = type == 'link' &&
      source.contains('/conversations/') &&
      (source.endsWith('.mp4') ||
          source.endsWith('.m4a') ||
          source.endsWith('.aac') ||
          source.endsWith('.mp3') ||
          source.endsWith('.wav') ||
          source.endsWith('.ogg') ||
          source.endsWith('.webm'));

  return isConversationRecording ||
      source.endsWith('.m4a') ||
      source.endsWith('.aac') ||
      source.endsWith('.mp3') ||
      source.endsWith('.wav') ||
      source.endsWith('.ogg') ||
      source.endsWith('.webm');
}

class _VoiceMessageContent extends StatefulWidget {
  const _VoiceMessageContent({
    required this.messageUrl,
    required this.isSent,
  });

  final String messageUrl;
  final bool isSent;

  @override
  State<_VoiceMessageContent> createState() => _VoiceMessageContentState();
}

class _VoiceMessageContentState extends State<_VoiceMessageContent> {
  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isReady = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player.positionStream.listen((value) {
      if (mounted) {
        setState(() {
          _position = value;
        });
      }
    });
    _player.durationStream.listen((value) {
      if (mounted) {
        setState(() {
          _duration = value ?? Duration.zero;
        });
      }
    });
    _player.playerStateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
      return;
    }

    if (!_isReady) {
      await _prepare();
    }

    if (_isReady) {
      await _player.play();
    }
  }

  Future<void> _prepare() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final source = widget.messageUrl.trim();
      if (File(source).existsSync()) {
        await _player.setFilePath(source);
      } else {
        await _player.setUrl(source);
      }

      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isReady = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.isSent ? Colors.white : const Color(0xFF111827);
    final secondary = widget.isSent
        ? Colors.white.withValues(alpha: 0.75)
        : const Color(0xFF6B7280);
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return SizedBox(
      width: 220,
      child: Row(
        children: [
          InkWell(
            onTap: _togglePlayback,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSent
                    ? Colors.white.withValues(alpha: 0.16)
                    : const Color(0xFFF3F4F6),
              ),
              child: Icon(
                _isLoading
                    ? Icons.hourglass_top_rounded
                    : _player.playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                color: foreground,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'chat_screen.voice_message'.tr(),
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 24,
                  child: _VoiceWaveform(
                    progress: progress,
                    isSent: widget.isSent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDuration(
                    _duration == Duration.zero ? _position : _duration,
                  ),
                  style: TextStyle(
                    color: secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _VoiceWaveform extends StatelessWidget {
  const _VoiceWaveform({
    required this.progress,
    required this.isSent,
  });

  final double progress;
  final bool isSent;

  static const List<double> _barHeights = <double>[
    8,
    14,
    11,
    18,
    10,
    16,
    20,
    12,
    9,
    17,
    13,
    19,
    10,
    15,
    21,
    12,
    8,
    16,
    11,
    18,
    9,
    14,
    20,
    12,
  ];

  @override
  Widget build(BuildContext context) {
    final activeColor = isSent ? Colors.white : Styles.PRIMARY_COLOR;
    final inactiveColor =
        isSent ? Colors.white.withValues(alpha: 0.22) : const Color(0xFFE5E7EB);
    final activeBars = (_barHeights.length * progress).ceil();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List<Widget>.generate(_barHeights.length, (index) {
        return Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: _barHeights[index],
              width: 3,
              decoration: BoxDecoration(
                color: index < activeBars ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      }),
    );
  }
}
