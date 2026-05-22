import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/data/realtime/pusher_service.dart';
import 'package:talent_flow/features/auth/pages/social_media_login/repo/chat_repo.dart';
import 'package:talent_flow/features/home/model/chat_model.dart';

class FreelancerChatBloc extends Bloc<AppEvent, AppState> {
  FreelancerChatBloc(this._chatRepo, this._pusherService) : super(Start()) {
    on<Add>(_onLoadConversation);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<_RefreshConversation>(_onRefreshConversation);
  }

  final ChatRepo _chatRepo;
  final PusherService _pusherService;
  int? _conversationId;
  ChatModel? _chat;
  String? _subscribedChannelName;
  Map<String, dynamic> _latestArgs = <String, dynamic>{};
  final Set<int> _messageIds = <int>{};
  final Set<String> _messageFingerprints = <String>{};
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // Buffer for messages that arrive before _chat is loaded
  final List<Message> _pendingMessages = [];

  Future<void> _onLoadConversation(Add event, Emitter<AppState> emit) async {
    final args = event.arguments;
    final Map<String, dynamic> mapArgs =
        args is Map<String, dynamic> ? args : <String, dynamic>{};
    _latestArgs = mapArgs;

    final dynamic rawConversationId = mapArgs['conversationId'];
    final dynamic rawFreelancerId = mapArgs['freelancerId'];
    final dynamic idRaw = rawConversationId ?? rawFreelancerId;
    final int? conversationId = idRaw is int
        ? idRaw
        : int.tryParse(idRaw?.toString() ?? '');
    final usedFallback = rawConversationId == null && rawFreelancerId != null;

    _logChatBloc(
      'loadConversation resolved identifiers',
      {
        'rawArgs': _summarizeMap(mapArgs),
        'rawConversationId': rawConversationId,
        'rawFreelancerId': rawFreelancerId,
        'resolvedConversationId': conversationId,
        'usedFreelancerFallback': usedFallback,
        'targetChannel': conversationId == null
            ? null
            : _pusherService.chatChannel(conversationId),
      },
    );

    if (conversationId == null) {
      _logChatBloc('loadConversation aborted: conversationId is null');
      emit(Empty(initial: true));
      return;
    }

    _conversationId = conversationId;
    await _loadConversation(emit: emit, showLoader: _chat == null);
    await _subscribeToConversation(conversationId: conversationId);
    _startPolling();
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<AppState> emit,
  ) async {
    final args = event.arguments;
    final Map<String, dynamic> mapArgs =
        args is Map<String, dynamic> ? args : <String, dynamic>{};

    final String body = (mapArgs['body'] ?? '').toString().trim();
    final String filePath = (mapArgs['filePath'] ?? '').toString().trim();
    if (body.isEmpty && filePath.isEmpty) {
      _logChatBloc('sendMessage ignored: empty body and filePath');
      return;
    }

    final dynamic rawId =
        mapArgs['conversationId'] ?? _conversationId ?? _latestArgs['conversationId'] ?? _latestArgs['freelancerId'];
    final int? conversationId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');
    final usedFreelancerFallback = mapArgs['conversationId'] == null &&
        _conversationId == null &&
        _latestArgs['conversationId'] == null &&
        _latestArgs['freelancerId'] != null;

    _logChatBloc(
      'sendMessage resolved identifiers',
      {
        'rawArgs': _summarizeMap(mapArgs),
        'blocConversationId': _conversationId,
        'latestConversationId': _latestArgs['conversationId'],
        'latestFreelancerId': _latestArgs['freelancerId'],
        'resolvedConversationId': conversationId,
        'usedFreelancerFallback': usedFreelancerFallback,
        'isFileMessage': filePath.isNotEmpty,
        'bodyLength': body.length,
        'filePath': filePath.isEmpty ? null : filePath,
      },
    );

    if (conversationId == null) {
      _logChatBloc('sendMessage aborted: conversationId is null');
      emit(Error());
      return;
    }

    _logChatBloc(
      'sendMessage request',
      {
        'conversationId': conversationId,
        'bodyPreview': _preview(body),
        'filePath': filePath.isEmpty ? null : filePath,
      },
    );

    final sendResult = filePath.isNotEmpty
        ? await _chatRepo.sendConversationFileMessage(
            conversationId: conversationId,
            file: File(filePath),
          )
        : await _chatRepo.sendConversationMessage(
            conversationId: conversationId,
            body: body,
          );

    await sendResult.fold(
      (failure) async {
        _logChatBloc(
          'sendMessage failure',
          {
            'conversationId': conversationId,
            'error': failure.error,
          },
        );
        emit(Error());
      },
      (response) async {
        _conversationId = conversationId;
        _logChatBloc(
          'sendMessage success',
          {
            'conversationId': conversationId,
            'responseRuntimeType': response.data.runtimeType.toString(),
            'responsePreview': _preview(response.data),
          },
        );
        final sentMessage = _extractMessageFromDynamic(response.data);
        if (sentMessage != null) {
          _logParsedMessage('sendMessage extracted message', sentMessage);
          _appendMessage(sentMessage, emit);
          return;
        }
        _logChatBloc(
          'sendMessage response could not be parsed into message; reloading conversation',
        );
        await _loadConversation(emit: emit, showLoader: false);
      },
    );
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<AppState> emit) {
    _logChatBloc(
      'receiveMessage event dispatched',
      {
        'messageRuntimeType': event.message.runtimeType.toString(),
        'messagePreview': _preview(event.message),
      },
    );

    final message = _extractMessageFromDynamic(event.message);
    if (message == null) {
      _logChatBloc(
        'receiveMessage parse failed: event payload did not match any candidate',
      );
      return;
    }

    _logParsedMessage('receiveMessage extracted message', message);
    _appendMessage(message, emit);
  }

  Future<void> _onRefreshConversation(
    _RefreshConversation event,
    Emitter<AppState> emit,
  ) async {
    if (_conversationId == null || _isRefreshing) {
      return;
    }

    _isRefreshing = true;
    try {
      await _loadConversation(emit: emit, showLoader: false);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _loadConversation({
    required Emitter<AppState> emit,
    required bool showLoader,
  }) async {
    final int? conversationId = _conversationId;
    if (conversationId == null) {
      _logChatBloc('_loadConversation aborted: _conversationId is null');
      emit(Empty(initial: true));
      return;
    }

    if (showLoader) {
      _logChatBloc(
        '_loadConversation emitting Loading',
        {'conversationId': conversationId},
      );
      emit(Loading());
    }

    _logChatBloc(
      '_loadConversation request',
      {
        'conversationId': conversationId,
        'showLoader': showLoader,
      },
    );
    final result = await _chatRepo.getConversationMessages(conversationId);
    result.fold(
      (failure) {
        _logChatBloc(
          '_loadConversation failure',
          {
            'conversationId': conversationId,
            'error': failure.error,
          },
        );
        emit(Error());
      },
      (chat) {
        final currentChat = _chat;
        final List<Message> updatedMessages = List<Message>.from(chat.messages);
        final apiLastMessage =
            updatedMessages.isNotEmpty ? updatedMessages.last : null;
        _logChatBloc(
          '_loadConversation success summary',
          {
            'conversationId': conversationId,
            'chatId': chat.id,
            'apiMessageCount': chat.messages.length,
            'receiverId': chat.receiver?.id,
            'receiverName': chat.receiver?.name,
            'apiLastMessageId': apiLastMessage?.id,
            'apiLastMessageType': apiLastMessage?.messageType,
            'apiLastMessageTime': apiLastMessage?.time,
            'currentCachedMessageCount': currentChat?.messages.length,
            'pendingMessageCount': _pendingMessages.length,
          },
        );
        _seedKnownMessages(updatedMessages);

        if (currentChat != null) {
          for (final existing in currentChat.messages) {
            if (!_isDuplicateMessage(existing)) {
              updatedMessages.add(existing);
            }
          }
        }

        // Flush any messages that arrived before the conversation was loaded
        if (_pendingMessages.isNotEmpty) {
          _logChatBloc(
            '_loadConversation flushing pending messages',
            {'pendingMessageCount': _pendingMessages.length},
          );
          for (final pending in _pendingMessages) {
            if (!_isDuplicateMessage(pending)) {
              updatedMessages.add(pending);
            }
          }
        }
        _pendingMessages.clear();

        _chat = chat.copyWith(messages: updatedMessages);
        _logChatBloc(
          '_loadConversation emitting Done',
          {
            'finalMessageCount': _chat!.messages.length,
            'finalLastMessageId':
                _chat!.messages.isNotEmpty ? _chat!.messages.last.id : null,
          },
        );
        emit(Done(data: _chat));
      },
    );
  }

  Future<void> _subscribeToConversation({required int conversationId}) async {
    final channelName = _pusherService.chatChannel(conversationId);
    if (_subscribedChannelName == channelName) {
      _logChatBloc(
        'subscribe skipped: already subscribed',
        {'channelName': channelName},
      );
      return;
    }

    if (_subscribedChannelName != null) {
      _logChatBloc(
        'subscribe switching channels',
        {
          'oldChannel': _subscribedChannelName,
          'newChannel': channelName,
        },
      );
      await _pusherService.unsubscribe(_subscribedChannelName!);
    }

    _subscribedChannelName = channelName;
    _logChatBloc(
      'subscribe start',
      {
        'conversationId': conversationId,
        'channelName': channelName,
      },
    );
    await _pusherService.subscribe(
      channelName: channelName,
      onEvent: (event) {
        if (isClosed) return;
        final dynamic rawEvent = event;
        final eventName = rawEvent.eventName?.toString() ?? '';
        if (eventName.startsWith('pusher:')) {
          _logChatBloc(
            'subscribe callback ignored internal event',
            {
              'channelName': rawEvent.channelName,
              'eventName': eventName,
            },
          );
          return;
        }
        _logChatBloc(
          'subscribe callback event received',
          {
            'channelName': rawEvent.channelName,
            'eventName': eventName,
            'dataType': rawEvent.data.runtimeType.toString(),
            'dataPreview': _preview(rawEvent.data),
          },
        );
        add(ReceiveMessage(message: event.data));
      },
    );
  }

  void _startPolling() {
    final conversationId = _conversationId;
    if (conversationId == null) {
      return;
    }

    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (isClosed || _conversationId == null) {
        return;
      }
      add(_RefreshConversation());
    });

    _logChatBloc(
      'polling started',
      {
        'conversationId': conversationId,
        'intervalSeconds': 4,
      },
    );
  }

  void _appendMessage(Message message, Emitter<AppState> emit) {
    _logChatBloc(
      '_appendMessage start',
      {
        'currentMessageCount': _chat?.messages.length,
        'pendingMessageCount': _pendingMessages.length,
      },
    );
    _logParsedMessage('_appendMessage candidate', message);
    if (_isDuplicateMessage(message)) {
      _logChatBloc(
        '_appendMessage skipped: duplicate message',
        {'messageId': message.id},
      );
      return;
    }

    final current = _chat;
    if (current == null) {
      // Chat not loaded yet — buffer the message so it's not lost
      _logChatBloc(
        '_appendMessage buffering because _chat is null',
        {
          'messageId': message.id,
          'pendingMessageCountBefore': _pendingMessages.length,
        },
      );
      _pendingMessages.add(message);
      return;
    }

    final List<Message> updatedMessages = List<Message>.from(current.messages)
      ..add(message);
    _chat = current.copyWith(messages: updatedMessages);
    _logChatBloc(
      '_appendMessage emitting Done',
      {
        'updatedMessageCount': updatedMessages.length,
        'lastMessageId': updatedMessages.last.id,
      },
    );
    emit(Done(data: _chat));
  }

  bool _isDuplicateMessage(Message message) {
    final int? id = message.id;
    if (id != null && _messageIds.contains(id)) {
      _logChatBloc(
        'duplicate detected by id',
        {
          'messageId': id,
          'fingerprint': _fingerprint(message),
        },
      );
      return true;
    }

    final fingerprint = _fingerprint(message);
    if (_messageFingerprints.contains(fingerprint)) {
      _logChatBloc(
        'duplicate detected by fingerprint',
        {
          'messageId': id,
          'fingerprint': fingerprint,
        },
      );
      return true;
    }

    if (id != null) {
      _messageIds.add(id);
    }
    _messageFingerprints.add(fingerprint);
    return false;
  }

  void _seedKnownMessages(List<Message> messages) {
    _logChatBloc(
      '_seedKnownMessages',
      {
        'messageCount': messages.length,
        'idsCount': messages.where((m) => m.id != null).length,
      },
    );
    _messageIds
      ..clear()
      ..addAll(messages.where((m) => m.id != null).map((m) => m.id!));

    _messageFingerprints
      ..clear()
      ..addAll(messages.map(_fingerprint));
  }

  String _fingerprint(Message message) {
    return [
      message.id?.toString() ?? '',
      message.messageType ?? '',
      message.message ?? '',
      message.sender?.id?.toString() ?? '',
      message.createdAt?.toIso8601String() ?? '',
      message.time ?? '',
    ].join('|');
  }

  Message? _extractMessageFromDynamic(dynamic raw) {
    _logChatBloc(
      '_extractMessageFromDynamic start',
      {
        'runtimeType': raw.runtimeType.toString(),
        'preview': _preview(raw),
      },
    );

    final root = _toJsonMap(raw);
    if (root == null) {
      _logChatBloc(
        '_extractMessageFromDynamic failed: root could not convert to Map',
      );
      return null;
    }

    final candidates = <dynamic>[
      root['payload'],
      (root['payload'] is Map ? (root['payload'] as Map)['message'] : null),
      root['data'],
      (root['data'] is Map ? (root['data'] as Map)['message'] : null),
      root['message'],
      root,
    ];

    for (int i = 0; i < candidates.length; i++) {
      final candidate = candidates[i];
      if (candidate == null) {
        _logChatBloc(
          '_extractMessageFromDynamic candidate skipped: null',
          {'candidateIndex': i},
        );
        continue;
      }

      final json = _toJsonMap(candidate);
      if (json == null) {
        _logChatBloc(
          '_extractMessageFromDynamic candidate could not convert to Map',
          {
            'candidateIndex': i,
            'candidateRuntimeType': candidate.runtimeType.toString(),
            'candidatePreview': _preview(candidate),
          },
        );
        continue;
      }

      try {
        final parsed = Message.fromJson(json);
        final hasAnyContent = _looksLikeMessagePayload(json, parsed);

        _logChatBloc(
          '_extractMessageFromDynamic candidate parsed',
          {
            'candidateIndex': i,
            'jsonKeys': json.keys.toList(),
            'hasContent': hasAnyContent,
          },
        );
        _logParsedMessage(
          '_extractMessageFromDynamic candidate[$i]',
          parsed,
        );

        if (hasAnyContent) {
          return parsed;
        }
      } catch (e) {
        _logChatBloc(
          '_extractMessageFromDynamic candidate parse threw',
          {
            'candidateIndex': i,
            'error': e.toString(),
            'candidatePreview': _preview(json),
          },
        );
        continue;
      }
    }

    _logChatBloc(
      '_extractMessageFromDynamic exhausted all candidates without match',
    );
    return null;
  }

  bool _looksLikeMessagePayload(Map<String, dynamic> json, Message parsed) {
    final hasMessageIdentity = parsed.id != null ||
        parsed.sender?.id != null ||
        parsed.createdAt != null ||
        (parsed.time ?? '').trim().isNotEmpty;
    final hasBody = (parsed.message ?? '').trim().isNotEmpty;

    if (json.containsKey('message_type') ||
        json.containsKey('body') ||
        json.containsKey('sender') ||
        json.containsKey('sender_id') ||
        json.containsKey('is_sent')) {
      return hasBody || hasMessageIdentity;
    }

    if ((json.containsKey('payload') || json.containsKey('status')) &&
        !json.containsKey('id')) {
      return false;
    }

    return hasBody || hasMessageIdentity;
  }

  Map<String, dynamic>? _toJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), val),
      );
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        return _toJsonMap(decoded);
      } catch (e) {
        _logChatBloc(
          '_toJsonMap failed to jsonDecode string',
          {
            'error': e.toString(),
            'preview': _preview(value),
          },
        );
        return null;
      }
    }

    return null;
  }

  @override
  Future<void> close() async {
    _refreshTimer?.cancel();
    if (_subscribedChannelName != null) {
      _logChatBloc(
        'close unsubscribing from active channel',
        {'channelName': _subscribedChannelName},
      );
      await _pusherService.unsubscribe(_subscribedChannelName!);
    }
    return super.close();
  }
}

class _RefreshConversation extends AppEvent {
  _RefreshConversation();
}

void _logChatBloc(String message, [Map<String, Object?> details = const {}]) {
  final suffix = details.isEmpty ? '' : ' | $details';
  log('[FreelancerChatBloc] $message$suffix', name: 'FreelancerChatBloc');
}

void _logParsedMessage(String label, Message message) {
  _logChatBloc(
    label,
    {
      'id': message.id,
      'messageType': message.messageType,
      'body': _preview(message.message),
      'isSent': message.isSent,
      'senderId': message.sender?.id,
      'createdAt': message.createdAt?.toIso8601String(),
      'time': message.time,
      'status': message.status,
    },
  );
}

Map<String, Object?> _summarizeMap(Map<String, dynamic> source) {
  final summary = <String, Object?>{};
  for (final entry in source.entries) {
    summary[entry.key] =
        entry.value is String ? _preview(entry.value) : entry.value?.toString();
  }
  return summary;
}

String _preview(dynamic value, {int max = 160}) {
  final text = value?.toString() ?? 'null';
  if (text.length <= max) {
    return text;
  }
  return '${text.substring(0, max)}…';
}
