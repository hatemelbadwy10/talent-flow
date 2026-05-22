import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/data/api/end_points.dart';
import 'package:talent_flow/data/error/api_error_handler.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/home/model/chat_model.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

class ChatRepo extends BaseRepo {
  ChatRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, int>> startConversation({
    required int userId,
    int? projectId,
  }) async {
    try {
      _logChatRepo(
        'startConversation request',
        {
          'userId': userId,
          'projectId': projectId,
        },
      );
      final response = await dioClient.post(
        uri: EndPoints.startConversation(userId),
        data: FormData.fromMap({
          if (projectId != null) 'project_id': projectId,
        }),
      );

      final dynamic data = response.data;
      final int? conversationId = _extractConversationId(data);
      _logChatRepo(
        'startConversation response',
        {
          'conversationId': conversationId,
          'responseKeys': _mapKeys(data),
        },
      );
      if (conversationId == null) {
        final message =
            data is Map<String, dynamic> ? data['message']?.toString() : null;
        return left(ServerFailure(message ?? 'Invalid conversation response'));
      }

      return Right(conversationId);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, ChatModel>> getConversationMessages(
    int conversationId,
  ) async {
    try {
      _logChatRepo(
        'getConversationMessages request',
        {'conversationId': conversationId},
      );
      final Response response = await dioClient.get(
        uri: EndPoints.conversationMessages(conversationId),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        _logChatRepo(
          'getConversationMessages invalid response',
          {'runtimeType': data.runtimeType.toString()},
        );
        return left(ServerFailure('Invalid response format'));
      }

      final payload = data['payload'];
      if (payload is Map<String, dynamic>) {
        final chat = ChatModel.fromJson(payload);
        _logConversationSummary(
          requestedConversationId: conversationId,
          source: 'payload',
          chat: chat,
        );
        return Right(chat);
      }

      final chat = ChatModel.fromJson(data);
      _logConversationSummary(
        requestedConversationId: conversationId,
        source: 'root',
        chat: chat,
      );
      return Right(chat);
    } catch (error) {
      _logChatRepo(
        'getConversationMessages error',
        {
          'conversationId': conversationId,
          'error': error.toString(),
        },
      );
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> sendConversationMessage({
    required int conversationId,
    required String body,
  }) async {
    try {
      _logChatRepo(
        'sendConversationMessage request',
        {
          'conversationId': conversationId,
          'bodyLength': body.length,
          'bodyPreview': body.length > 80 ? '${body.substring(0, 80)}…' : body,
        },
      );
      final response = await dioClient.post(
        uri: EndPoints.sendConversationMessage,
        data: {
          'conversation_id': conversationId,
          'body': body,
        },
      );
      _logSendResponse(
        label: 'sendConversationMessage response',
        responseData: response.data,
      );
      return Right(response);
    } catch (error) {
      _logChatRepo(
        'sendConversationMessage error',
        {
          'conversationId': conversationId,
          'error': error.toString(),
        },
      );
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> sendConversationFileMessage({
    required int conversationId,
    required File file,
  }) async {
    try {
      _logChatRepo(
        'sendConversationFileMessage request',
        {
          'conversationId': conversationId,
          'filePath': file.path,
          'exists': file.existsSync(),
          'fileLength': file.existsSync() ? file.lengthSync() : null,
        },
      );
      final response = await dioClient.post(
        uri: EndPoints.sendConversationMessage,
        data: FormData.fromMap(
          {
            'conversation_id': conversationId,
            'file': await MultipartFile.fromFile(file.path),
          },
        ),
      );
      _logSendResponse(
        label: 'sendConversationFileMessage response',
        responseData: response.data,
      );
      return Right(response);
    } catch (error) {
      _logChatRepo(
        'sendConversationFileMessage error',
        {
          'conversationId': conversationId,
          'filePath': file.path,
          'error': error.toString(),
        },
      );
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  int? _extractConversationId(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final dynamic payload = raw['payload'];
      final dynamic data = raw['data'];

      return _parseInt(payload?['id']) ??
          _parseInt(data?['id']) ??
          _parseInt(raw['id']) ??
          _extractConversationId(payload) ??
          _extractConversationId(data);
    }

    if (raw is Map) {
      return _extractConversationId(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    return null;
  }

  int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }
}

void _logChatRepo(String message, [Map<String, Object?> details = const {}]) {
  final suffix = details.isEmpty ? '' : ' | $details';
  log('[ChatRepo] $message$suffix', name: 'ChatRepo');
}

void _logConversationSummary({
  required int requestedConversationId,
  required String source,
  required ChatModel chat,
}) {
  final latestMessage = chat.messages.isNotEmpty ? chat.messages.last : null;
  _logChatRepo(
    'getConversationMessages summary',
    {
      'requestedConversationId': requestedConversationId,
      'source': source,
      'returnedChatId': chat.id,
      'messageCount': chat.messages.length,
      'receiverId': chat.receiver?.id,
      'receiverName': chat.receiver?.name,
      'latestMessageId': latestMessage?.id,
      'latestMessageTime': latestMessage?.time,
      'latestMessageType': latestMessage?.messageType,
    },
  );
}

void _logSendResponse({
  required String label,
  required dynamic responseData,
}) {
  final messageJson = _extractMessageMap(responseData);
  _logChatRepo(
    label,
    {
      'responseKeys': _mapKeys(responseData),
      'messageId': messageJson?['id'],
      'messageBody': messageJson?['message'],
      'messageType': messageJson?['message_type'],
    },
  );
}

List<String> _mapKeys(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value.keys.toList();
  }
  if (value is Map) {
    return value.keys.map((key) => key.toString()).toList();
  }
  return const [];
}

Map<String, dynamic>? _extractMessageMap(dynamic raw) {
  final map = _normalizeMap(raw);
  if (map == null) return null;

  final candidates = <dynamic>[
    map,
    map['message'],
    map['data'],
    map['payload'],
    (map['data'] is Map ? (map['data'] as Map)['message'] : null),
    (map['payload'] is Map ? (map['payload'] as Map)['message'] : null),
  ];

  for (final candidate in candidates) {
    final json = _normalizeMap(candidate);
    if (json == null) continue;
    if (json.containsKey('id') ||
        json.containsKey('message') ||
        json.containsKey('message_type')) {
      return json;
    }
  }

  return null;
}

Map<String, dynamic>? _normalizeMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}
