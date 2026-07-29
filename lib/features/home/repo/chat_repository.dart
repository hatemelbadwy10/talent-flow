import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/chat_model.dart';

abstract interface class ChatRepository {
  Future<Either<ServerFailure, int>> startConversation({
    required int userId,
    int? projectId,
  });

  Future<Either<ServerFailure, ChatModel>> getConversationMessages(
    int conversationId, {
    String? search,
  });

  Future<Either<ServerFailure, Message?>> sendConversationMessage({
    required int conversationId,
    required String body,
  });

  Future<Either<ServerFailure, Message?>> sendConversationFileMessage({
    required int conversationId,
    required File file,
  });
}
