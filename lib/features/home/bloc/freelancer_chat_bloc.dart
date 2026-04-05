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
  }

  static const Set<String> _messageEventNames = <String>{
    '.message.sent',
    'message.sent',
  };

  final ChatRepo _chatRepo;
  final PusherService _pusherService;
  int? _conversationId;
  ChatModel? _chat;
  String? _subscribedChannelName;
  Map<String, dynamic> _latestArgs = <String, dynamic>{};
  final Set<int> _messageIds = <int>{};
  final Set<String> _messageFingerprints = <String>{};

  // Buffer for messages that arrive before _chat is loaded
  final List<Message> _pendingMessages = [];

  Future<void> _onLoadConversation(Add event, Emitter<AppState> emit) async {
    final args = event.arguments;
    final Map<String, dynamic> mapArgs =
        args is Map<String, dynamic> ? args : <String, dynamic>{};
    _latestArgs = mapArgs;

    final dynamic idRaw = mapArgs['conversationId'] ?? mapArgs['freelancerId'];
    final int? conversationId =
        idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');

    if (conversationId == null) {
      log('FreelancerChatBloc: conversationId is null, emitting Empty');
      emit(Empty(initial: true));
      return;
    }

    _conversationId = conversationId;
    await _loadConversation(emit: emit, showLoader: true);
    await _subscribeToConversation(conversationId: conversationId);
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
      log('FreelancerChatBloc: body and filePath are both empty, ignoring send');
      return;
    }

    final dynamic rawId = mapArgs['conversationId'] ??
        _conversationId ??
        _latestArgs['conversationId'] ??
        _latestArgs['freelancerId'];
    final int? conversationId =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    if (conversationId == null) {
      log('FreelancerChatBloc: conversationId is null on send, emitting Error');
      emit(Error());
      return;
    }

    log('FreelancerChatBloc: sending message to conversation $conversationId');

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
        log('FreelancerChatBloc send error: ${failure.error}');
        emit(Error());
      },
      (response) async {
        _conversationId = conversationId;
        log('FreelancerChatBloc: send success, raw response data: ${response.data}');
        final sentMessage = _normalizeSentMessage(
          _extractMessageFromDynamic(response.data),
          body: body,
          filePath: filePath,
        );
        if (sentMessage != null) {
          log('FreelancerChatBloc: extracted sent message id=${sentMessage.id}');
          _appendMessage(sentMessage, emit);
          return;
        }
        log('FreelancerChatBloc: could not extract sent message from response, appending optimistic message then reloading conversation');
        _appendMessage(
          _buildOptimisticMessage(body: body, filePath: filePath),
          emit,
        );
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await _loadConversation(emit: emit, showLoader: false);
      },
    );
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<AppState> emit) {
    log('FreelancerChatBloc: RAW pusher event data: ${event.message}');

    final message = _extractMessageFromDynamic(event.message);
    if (message == null) {
      log('FreelancerChatBloc: _extractMessageFromDynamic returned null — pusher data shape does not match any candidate');
      return;
    }

    log('FreelancerChatBloc: extracted pusher message id=${message.id}, body=${message.message}');
    _appendMessage(message, emit);
  }

  Future<void> _loadConversation({
    required Emitter<AppState> emit,
    required bool showLoader,
  }) async {
    final int? conversationId = _conversationId;
    if (conversationId == null) {
      log('FreelancerChatBloc: _loadConversation called but _conversationId is null');
      emit(Empty(initial: true));
      return;
    }

    if (showLoader) {
      emit(Loading());
    }

    final result = await _chatRepo.getConversationMessages(conversationId);
    result.fold(
      (failure) {
        log('FreelancerChatBloc error loading conversation: ${failure.error}');
        emit(Error());
      },
      (chat) {
        _chat = chat;
        _seedKnownMessages(chat.messages);

        // Flush any messages that arrived before the conversation was loaded
        if (_pendingMessages.isNotEmpty) {
          log('FreelancerChatBloc: flushing ${_pendingMessages.length} pending messages');
          final List<Message> updatedMessages =
              List<Message>.from(chat.messages);
          for (final pending in _pendingMessages) {
            if (!_isDuplicateMessage(pending)) {
              updatedMessages.add(pending);
            }
          }
          _pendingMessages.clear();
          _chat = chat.copyWith(messages: updatedMessages);
        }

        log('FreelancerChatBloc: loaded conversation with ${_chat!.messages.length} messages');
        emit(Done(data: _chat));
      },
    );
  }

  Future<void> _subscribeToConversation({required int conversationId}) async {
    final channelName = _pusherService.chatChannel(conversationId);
    if (_subscribedChannelName == channelName) {
      log('FreelancerChatBloc: already subscribed to $channelName, skipping');
      return;
    }

    if (_subscribedChannelName != null) {
      log('FreelancerChatBloc: unsubscribing from $_subscribedChannelName');
      await _pusherService.unsubscribe(_subscribedChannelName!);
    }

    log('FreelancerChatBloc: subscribing to $channelName');
    try {
      await _pusherService.subscribe(
        channelName: channelName,
        onEvent: (event) {
          if (isClosed) return;
          log(
            'FreelancerChatBloc: pusher event received on $channelName '
            'event=${event.eventName} data=${event.data}',
          );
          if (!_messageEventNames.contains(event.eventName)) {
            log(
              'FreelancerChatBloc: skipping non-message event ${event.eventName}',
            );
            return;
          }
          add(ReceiveMessage(message: event.data));
        },
      );
      _subscribedChannelName = channelName;
    } catch (error, stackTrace) {
      _subscribedChannelName = null;
      log(
        'FreelancerChatBloc: subscribe failed for $channelName: $error',
        stackTrace: stackTrace,
      );
    }
  }

  void _appendMessage(Message message, Emitter<AppState> emit) {
    if (_isDuplicateMessage(message)) {
      log('FreelancerChatBloc: duplicate message skipped id=${message.id}');
      return;
    }

    final current = _chat;
    if (current == null) {
      // Chat not loaded yet — buffer the message so it's not lost
      log('FreelancerChatBloc: _chat is null, buffering message id=${message.id} until conversation loads');
      _pendingMessages.add(message);
      return;
    }

    final List<Message> updatedMessages = List<Message>.from(current.messages)
      ..add(message);
    _chat = current.copyWith(messages: updatedMessages);
    log('FreelancerChatBloc: emitting Done with ${updatedMessages.length} messages');
    emit(Done(data: _chat));
  }

  bool _isDuplicateMessage(Message message) {
    final int? id = message.id;
    if (id != null && _messageIds.contains(id)) {
      log('FreelancerChatBloc: duplicate by id: $id');
      return true;
    }

    final fingerprint = _fingerprint(message);
    if (_messageFingerprints.contains(fingerprint)) {
      log('FreelancerChatBloc: duplicate by fingerprint: $fingerprint');
      return true;
    }

    if (id != null) {
      _messageIds.add(id);
    }
    _messageFingerprints.add(fingerprint);
    return false;
  }

  void _seedKnownMessages(List<Message> messages) {
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

  Message? _normalizeSentMessage(
    Message? message, {
    required String body,
    required String filePath,
  }) {
    if (message == null) {
      return null;
    }

    final fallbackBody = body.isNotEmpty
        ? body
        : (filePath.isNotEmpty
            ? filePath.split(Platform.pathSeparator).last
            : '');

    return message.copyWith(
      message: (message.message ?? '').trim().isNotEmpty
          ? message.message
          : fallbackBody,
      messageType: (message.messageType ?? '').trim().isNotEmpty
          ? message.messageType
          : (filePath.isNotEmpty ? 'file' : 'text'),
      isSent: message.isSent ?? true,
      createdAt: message.createdAt ?? DateTime.now(),
      status:
          (message.status ?? '').trim().isNotEmpty ? message.status : 'sent',
    );
  }

  Message _buildOptimisticMessage({
    required String body,
    required String filePath,
  }) {
    final fallbackBody = body.isNotEmpty
        ? body
        : (filePath.isNotEmpty
            ? filePath.split(Platform.pathSeparator).last
            : '');

    return Message(
      id: null,
      messageType: filePath.isNotEmpty ? 'file' : 'text',
      message: fallbackBody,
      isSent: true,
      sender: null,
      createdAt: DateTime.now(),
      time: '',
      status: 'sent',
    );
  }

  Message? _extractMessageFromDynamic(dynamic raw) {
    log('FreelancerChatBloc: _extractMessageFromDynamic input type=${raw.runtimeType}, value=$raw');

    final root = _toJsonMap(raw);
    if (root == null) {
      log('FreelancerChatBloc: could not convert raw to Map, extraction failed');
      return null;
    }

    final candidates = <dynamic>[
      root,
      root['message'],
      root['data'],
      root['payload'],
      (root['data'] is Map ? (root['data'] as Map)['message'] : null),
      (root['payload'] is Map ? (root['payload'] as Map)['message'] : null),
      (root['payload'] is Map ? (root['payload'] as Map)['data'] : null),
      (root['data'] is Map ? (root['data'] as Map)['payload'] : null),
    ];

    for (int i = 0; i < candidates.length; i++) {
      final candidate = candidates[i];
      if (candidate == null) continue;

      final json = _toJsonMap(candidate);
      if (json == null) {
        log('FreelancerChatBloc: candidate[$i] could not be converted to Map');
        continue;
      }

      try {
        final parsed = Message.fromJson(json);
        final hasAnyContent = (parsed.message ?? '').trim().isNotEmpty ||
            parsed.id != null ||
            (parsed.time ?? '').trim().isNotEmpty;

        log('FreelancerChatBloc: candidate[$i] parsed — id=${parsed.id}, message=${parsed.message}, hasContent=$hasAnyContent');

        if (hasAnyContent) {
          return parsed;
        }
      } catch (e) {
        log('FreelancerChatBloc: candidate[$i] Message.fromJson threw: $e');
        continue;
      }
    }

    log('FreelancerChatBloc: all candidates exhausted, returning null');
    return null;
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
      final trimmed = value.trim();
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        return null;
      }

      try {
        final decoded = jsonDecode(trimmed);
        return _toJsonMap(decoded);
      } catch (e) {
        log('FreelancerChatBloc: _toJsonMap failed to jsonDecode string: $e');
        return null;
      }
    }

    return null;
  }

  @override
  Future<void> close() async {
    if (_subscribedChannelName != null) {
      log('FreelancerChatBloc: closing, unsubscribing from $_subscribedChannelName');
      await _pusherService.unsubscribe(_subscribedChannelName!);
    }
    return super.close();
  }
}
