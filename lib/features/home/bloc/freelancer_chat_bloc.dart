import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/data/realtime/realtime_chat_service.dart';
import 'package:talent_flow/features/home/model/chat_model.dart';
import 'package:talent_flow/features/home/repo/chat_repository.dart';

sealed class FreelancerChatEvent {
  const FreelancerChatEvent();
}

final class ConversationRequested extends FreelancerChatEvent {
  const ConversationRequested({
    this.conversationId,
    this.freelancerId,
  });

  final int? conversationId;
  final int? freelancerId;
}

final class ChatMessagesSearched extends FreelancerChatEvent {
  const ChatMessagesSearched(this.query);

  final String query;
}

final class ChatMessageSent extends FreelancerChatEvent {
  const ChatMessageSent({
    this.conversationId,
    this.body = '',
    this.filePath = '',
  });

  final int? conversationId;
  final String body;
  final String filePath;
}

final class RealtimeChatMessageReceived extends FreelancerChatEvent {
  const RealtimeChatMessageReceived(this.message);

  final Object? message;
}

final class _RefreshConversation extends FreelancerChatEvent {
  const _RefreshConversation();
}

sealed class FreelancerChatState {
  const FreelancerChatState();
}

final class FreelancerChatInitial extends FreelancerChatState {
  const FreelancerChatInitial();
}

final class FreelancerChatLoading extends FreelancerChatState {
  const FreelancerChatLoading();
}

final class FreelancerChatLoaded extends FreelancerChatState {
  const FreelancerChatLoaded(this.chat);

  final ChatModel chat;
}

final class FreelancerChatEmpty extends FreelancerChatState {
  const FreelancerChatEmpty();
}

final class FreelancerChatFailed extends FreelancerChatState {
  const FreelancerChatFailed(this.message);

  final String message;
}

class FreelancerChatBloc
    extends Bloc<FreelancerChatEvent, FreelancerChatState> {
  FreelancerChatBloc({
    required ChatRepository repository,
    required RealtimeChatService realtimeService,
  })  : _chatRepo = repository,
        _realtimeService = realtimeService,
        super(const FreelancerChatInitial()) {
    on<ConversationRequested>(_onLoadConversation);
    on<ChatMessagesSearched>(_onSearchMessages);
    on<ChatMessageSent>(_onSendMessage);
    on<RealtimeChatMessageReceived>(_onReceiveMessage);
    on<_RefreshConversation>(_onRefreshConversation);
  }

  final ChatRepository _chatRepo;
  final RealtimeChatService _realtimeService;
  int? _conversationId;
  ChatModel? _chat;
  String? _subscribedChannelName;
  String _messageSearch = '';
  int? _fallbackFreelancerId;
  final Set<int> _messageIds = <int>{};
  final Set<String> _messageFingerprints = <String>{};
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // Buffer for messages that arrive before _chat is loaded
  final List<Message> _pendingMessages = [];

  Future<void> _onLoadConversation(
    ConversationRequested event,
    Emitter<FreelancerChatState> emit,
  ) async {
    _fallbackFreelancerId = event.freelancerId;
    final conversationId = event.conversationId ?? event.freelancerId;
    final usedFallback =
        event.conversationId == null && event.freelancerId != null;

    _logChatBloc(
      'loadConversation resolved identifiers',
      {
        'rawConversationId': event.conversationId,
        'rawFreelancerId': event.freelancerId,
        'resolvedConversationId': conversationId,
        'usedFreelancerFallback': usedFallback,
        'targetChannel': conversationId == null
            ? null
            : _realtimeService.chatChannel(conversationId),
      },
    );

    if (conversationId == null) {
      _logChatBloc('loadConversation aborted: conversationId is null');
      emit(const FreelancerChatEmpty());
      return;
    }

    _conversationId = conversationId;
    await _loadConversation(emit: emit, showLoader: _chat == null);
    await _subscribeToConversation(conversationId: conversationId);
    _startPolling();
  }

  Future<void> _onSearchMessages(
    ChatMessagesSearched event,
    Emitter<FreelancerChatState> emit,
  ) async {
    _messageSearch = event.query.trim();
    await _loadConversation(emit: emit, showLoader: true);
  }

  Future<void> _onSendMessage(
    ChatMessageSent event,
    Emitter<FreelancerChatState> emit,
  ) async {
    final body = event.body.trim();
    final filePath = event.filePath.trim();
    if (body.isEmpty && filePath.isEmpty) {
      _logChatBloc('sendMessage ignored: empty body and filePath');
      return;
    }

    final conversationId =
        event.conversationId ?? _conversationId ?? _fallbackFreelancerId;
    final usedFreelancerFallback = event.conversationId == null &&
        _conversationId == null &&
        _fallbackFreelancerId != null;

    _logChatBloc(
      'sendMessage resolved identifiers',
      {
        'blocConversationId': _conversationId,
        'latestFreelancerId': _fallbackFreelancerId,
        'resolvedConversationId': conversationId,
        'usedFreelancerFallback': usedFreelancerFallback,
        'isFileMessage': filePath.isNotEmpty,
        'bodyLength': body.length,
        'filePath': filePath.isEmpty ? null : filePath,
      },
    );

    if (conversationId == null) {
      _logChatBloc('sendMessage aborted: conversationId is null');
      emit(const FreelancerChatFailed('Invalid conversation'));
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
        emit(FreelancerChatFailed(failure.error));
      },
      (sentMessage) async {
        _conversationId = conversationId;
        _logChatBloc(
          'sendMessage success',
          {
            'conversationId': conversationId,
            'messageId': sentMessage?.id,
          },
        );
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

  void _onReceiveMessage(
    RealtimeChatMessageReceived event,
    Emitter<FreelancerChatState> emit,
  ) {
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
    Emitter<FreelancerChatState> emit,
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
    required Emitter<FreelancerChatState> emit,
    required bool showLoader,
  }) async {
    final int? conversationId = _conversationId;
    if (conversationId == null) {
      _logChatBloc('_loadConversation aborted: _conversationId is null');
      emit(const FreelancerChatEmpty());
      return;
    }

    if (showLoader) {
      _logChatBloc(
        '_loadConversation emitting Loading',
        {'conversationId': conversationId},
      );
      emit(const FreelancerChatLoading());
    }

    _logChatBloc(
      '_loadConversation request',
      {
        'conversationId': conversationId,
        'showLoader': showLoader,
      },
    );
    final search = _messageSearch.trim();
    final result = await _chatRepo.getConversationMessages(
      conversationId,
      search: search,
    );
    result.fold(
      (failure) {
        _logChatBloc(
          '_loadConversation failure',
          {
            'conversationId': conversationId,
            'error': failure.error,
          },
        );
        emit(FreelancerChatFailed(failure.error));
      },
      (chat) {
        final currentChat = _chat;
        final List<Message> updatedMessages = List<Message>.from(chat.messages);
        final isSearchActive = search.isNotEmpty;
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
            'isSearchActive': isSearchActive,
          },
        );
        _seedKnownMessages(updatedMessages);

        if (currentChat != null && !isSearchActive) {
          for (final existing in currentChat.messages) {
            if (!_isDuplicateMessage(existing)) {
              updatedMessages.add(existing);
            }
          }
        }

        // Flush any messages that arrived before the conversation was loaded
        if (_pendingMessages.isNotEmpty && !isSearchActive) {
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
        updatedMessages.sort(Message.compareChronologically);

        _chat = chat.copyWith(messages: updatedMessages);
        _logChatBloc(
          '_loadConversation emitting Done',
          {
            'finalMessageCount': _chat!.messages.length,
            'finalLastMessageId':
                _chat!.messages.isNotEmpty ? _chat!.messages.last.id : null,
          },
        );
        emit(FreelancerChatLoaded(_chat!));
      },
    );
  }

  Future<void> _subscribeToConversation({required int conversationId}) async {
    final channelName = _realtimeService.chatChannel(conversationId);
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
      await _realtimeService.unsubscribe(_subscribedChannelName!);
    }

    _subscribedChannelName = channelName;
    _logChatBloc(
      'subscribe start',
      {
        'conversationId': conversationId,
        'channelName': channelName,
      },
    );
    await _realtimeService.subscribe(
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
        add(RealtimeChatMessageReceived(event.data));
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
      add(const _RefreshConversation());
    });

    _logChatBloc(
      'polling started',
      {
        'conversationId': conversationId,
        'intervalSeconds': 4,
      },
    );
  }

  void _appendMessage(
    Message message,
    Emitter<FreelancerChatState> emit,
  ) {
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
      ..add(message)
      ..sort(Message.compareChronologically);
    _chat = current.copyWith(messages: updatedMessages);
    _logChatBloc(
      '_appendMessage emitting Done',
      {
        'updatedMessageCount': updatedMessages.length,
        'lastMessageId': updatedMessages.last.id,
      },
    );
    emit(FreelancerChatLoaded(_chat!));
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
      await _realtimeService.unsubscribe(_subscribedChannelName!);
    }
    return super.close();
  }
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

String _preview(dynamic value, {int max = 160}) {
  final text = value?.toString() ?? 'null';
  if (text.length <= max) {
    return text;
  }
  return '${text.substring(0, max)}…';
}
