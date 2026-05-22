import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/data/realtime/pusher_service.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class UserChannelRealtimeService {
  UserChannelRealtimeService({
    required SharedPreferences sharedPreferences,
    required PusherService pusherService,
  })  : _sharedPreferences = sharedPreferences,
        _pusherService = pusherService;

  final SharedPreferences _sharedPreferences;
  final PusherService _pusherService;

  String? _subscribedChannelName;
  int? _subscribedUserId;

  Future<void> syncSessionSubscription() async {
    final token = _sharedPreferences.getString(AppStorageKey.token)?.trim() ?? '';
    final rawUserId =
        _sharedPreferences.getString(AppStorageKey.userId)?.trim() ?? '';
    final userId = int.tryParse(rawUserId);

    if (token.isEmpty || userId == null) {
      _logUserChannel(
        'syncSessionSubscription no active session',
        {
          'hasToken': token.isNotEmpty,
          'rawUserId': rawUserId,
        },
      );
      await clearSubscription();
      return;
    }

    final channelName = _pusherService.userChannel(userId);
    if (_subscribedChannelName == channelName && _subscribedUserId == userId) {
      _logUserChannel(
        'syncSessionSubscription already subscribed',
        {
          'channelName': channelName,
          'userId': userId,
        },
      );
      return;
    }

    if (_subscribedChannelName != null) {
      _logUserChannel(
        'syncSessionSubscription switching subscription',
        {
          'oldChannel': _subscribedChannelName,
          'newChannel': channelName,
        },
      );
      await _pusherService.unsubscribe(_subscribedChannelName!);
    }

    _subscribedChannelName = channelName;
    _subscribedUserId = userId;
    _logUserChannel(
      'subscribe user channel',
      {
        'channelName': channelName,
        'userId': userId,
      },
    );
    await _pusherService.subscribe(
      channelName: channelName,
      onEvent: _handleUserChannelEvent,
    );
  }

  Future<void> clearSubscription() async {
    if (_subscribedChannelName == null) {
      return;
    }

    _logUserChannel(
      'clearSubscription',
      {'channelName': _subscribedChannelName},
    );
    await _pusherService.unsubscribe(_subscribedChannelName!);
    _subscribedChannelName = null;
    _subscribedUserId = null;
  }

  void _handleUserChannelEvent(dynamic event) {
    final dynamic rawEvent = event;
    final eventName = rawEvent.eventName?.toString() ?? '';
    final data = rawEvent.data;

    if (eventName.startsWith('pusher:')) {
      _logUserChannel(
        'ignore internal pusher event',
        {
          'eventName': eventName,
          'channelName': rawEvent.channelName?.toString(),
        },
      );
      return;
    }

    final payload = _normalizeMap(data);
    _logUserChannel(
      'user channel event received',
      {
        'channelName': rawEvent.channelName?.toString(),
        'eventName': eventName,
        'dataType': data.runtimeType.toString(),
        'dataPreview': _preview(data),
        'payloadKeys': payload?.keys.toList(),
      },
    );

    final conversationId = _extractInt(payload, const [
      ['conversation_id'],
      ['conversationId'],
      ['message', 'conversation_id'],
      ['message', 'conversationId'],
      ['conversation', 'id'],
      ['message', 'conversation', 'id'],
      ['payload', 'conversation_id'],
      ['payload', 'conversationId'],
      ['payload', 'message', 'conversation_id'],
      ['payload', 'message', 'conversationId'],
      ['payload', 'conversation', 'id'],
      ['payload', 'message', 'conversation', 'id'],
      ['data', 'conversation_id'],
      ['data', 'conversationId'],
      ['data', 'message', 'conversation_id'],
      ['data', 'message', 'conversationId'],
      ['data', 'conversation', 'id'],
      ['data', 'message', 'conversation', 'id'],
    ]);
    final projectId = _extractInt(payload, const [
      ['project_id'],
      ['projectId'],
      ['message', 'project_id'],
      ['message', 'projectId'],
      ['message', 'conversation', 'project_id'],
      ['message', 'conversation', 'projectId'],
      ['payload', 'project_id'],
      ['payload', 'projectId'],
      ['payload', 'message', 'project_id'],
      ['payload', 'message', 'projectId'],
      ['payload', 'message', 'conversation', 'project_id'],
      ['payload', 'message', 'conversation', 'projectId'],
      ['data', 'project_id'],
      ['data', 'projectId'],
      ['data', 'message', 'project_id'],
      ['data', 'message', 'projectId'],
      ['data', 'message', 'conversation', 'project_id'],
      ['data', 'message', 'conversation', 'projectId'],
    ]);
    final unreadMessagesCount = _extractInt(payload, const [
      ['unread_messages_count'],
      ['payload', 'unread_messages_count'],
      ['data', 'unread_messages_count'],
    ]);

    final senderName = _extractText(payload, const [
      ['sender', 'name'],
      ['user', 'name'],
      ['message', 'sender', 'name'],
      ['message', 'user', 'name'],
      ['message', 'conversation', 'user_one', 'name'],
      ['message', 'conversation', 'user_two', 'name'],
      ['payload', 'sender', 'name'],
      ['payload', 'user', 'name'],
      ['payload', 'message', 'sender', 'name'],
      ['payload', 'message', 'user', 'name'],
      ['payload', 'message', 'conversation', 'user_one', 'name'],
      ['payload', 'message', 'conversation', 'user_two', 'name'],
      ['data', 'sender', 'name'],
      ['data', 'user', 'name'],
      ['data', 'message', 'sender', 'name'],
      ['data', 'message', 'user', 'name'],
      ['data', 'message', 'conversation', 'user_one', 'name'],
      ['data', 'message', 'conversation', 'user_two', 'name'],
      ['name'],
      ['title'],
    ]);

    final messageText = _extractText(payload, const [
      ['body'],
      ['text'],
      ['message', 'body'],
      ['message', 'text'],
      ['message', 'message'],
      ['payload', 'message'],
      ['payload', 'body'],
      ['payload', 'text'],
      ['payload', 'message', 'body'],
      ['payload', 'message', 'text'],
      ['payload', 'message', 'message'],
      ['data', 'message'],
      ['data', 'body'],
      ['data', 'text'],
      ['data', 'message', 'body'],
      ['data', 'message', 'text'],
      ['data', 'message', 'message'],
    ]);

    _syncUnreadMessages(unreadMessagesCount);
    _showNewMessageBanner(
      conversationId: conversationId,
      projectId: projectId,
      senderName: senderName,
      messageText: messageText,
    );
  }

  void _syncUnreadMessages(int? exactCount) {
    final nextCount = exactCount ?? (_currentUnreadMessagesCount() + 1);
    _logUserChannel(
      'sync unread messages count',
      {
        'exactCount': exactCount,
        'nextCount': nextCount,
      },
    );
    UserBloc.instance.add(
      SyncUnreadCounts(arguments: {'messages': nextCount}),
    );
  }

  int _currentUnreadMessagesCount() {
    final raw = _sharedPreferences.getString(AppStorageKey.userData);
    if ((raw ?? '').isEmpty) {
      return 0;
    }

    try {
      final decoded = jsonDecode(raw!);
      final map = _normalizeMap(decoded);
      return _toInt(map?['unread_messages_count']) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  void _showNewMessageBanner({
    required int? conversationId,
    required int? projectId,
    required String? senderName,
    required String? messageText,
  }) {
    final displayMessage = [
      if ((senderName ?? '').trim().isNotEmpty) senderName!.trim(),
      if ((messageText ?? '').trim().isNotEmpty) messageText!.trim(),
    ].join(': ');

    final message = displayMessage.isNotEmpty
        ? displayMessage
        : 'You have a new message';

    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Styles.PRIMARY_COLOR,
        borderColor: Colors.transparent,
        isFloating: true,
        withAction: true,
        action: TextButton(
          onPressed: () {
            AppCore.hideSnackBar();
            if (conversationId != null) {
              CustomNavigator.push(
                Routes.chat,
                arguments: {
                  'conversationId': conversationId,
                  if (projectId != null) 'projectId': projectId,
                  if (projectId != null) 'project_id': projectId,
                  if ((senderName ?? '').trim().isNotEmpty)
                    'freelancerName': senderName,
                },
              );
              return;
            }
            CustomNavigator.push(Routes.chats);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

void _logUserChannel(String message, [Map<String, Object?> details = const {}]) {
  final suffix = details.isEmpty ? '' : ' | $details';
  log('[UserChannelRealtimeService] $message$suffix',
      name: 'UserChannelRealtimeService');
}

Map<String, dynamic>? _normalizeMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      return _normalizeMap(decoded);
    } catch (_) {
      return null;
    }
  }
  return null;
}

dynamic _readPath(Map<String, dynamic>? source, List<String> path) {
  dynamic current = source;
  for (final segment in path) {
    if (current is Map<String, dynamic>) {
      current = current[segment];
    } else if (current is Map) {
      current = current[segment];
    } else {
      return null;
    }
  }
  return current;
}

int? _extractInt(Map<String, dynamic>? source, List<List<String>> paths) {
  for (final path in paths) {
    final value = _readPath(source, path);
    final parsed = _toInt(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

String? _extractText(Map<String, dynamic>? source, List<List<String>> paths) {
  for (final path in paths) {
    final value = _readPath(source, path)?.toString().trim() ?? '';
    if (value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String _preview(dynamic value, {int max = 180}) {
  final text = value?.toString() ?? 'null';
  if (text.length <= max) {
    return text;
  }
  return '${text.substring(0, max)}…';
}
