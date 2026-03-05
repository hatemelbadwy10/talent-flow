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

  Future<Either<ServerFailure, ChatModel>> getConversationMessages(
    int conversationId,
  ) async {
    try {
      final Response response = await dioClient.get(
        uri: EndPoints.conversationMessages(conversationId),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return left(ServerFailure('Invalid response format'));
      }

      final payload = data['payload'];
      if (payload is Map<String, dynamic>) {
        return Right(ChatModel.fromJson(payload));
      }

      return Right(ChatModel.fromJson(data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> sendConversationMessage({
    required int conversationId,
    required String body,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.sendConversationMessage,
        data: {
          'conversation_id': conversationId,
          'body': body,
        },
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, Response>> sendConversationFileMessage({
    required int conversationId,
    required File file,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.sendConversationMessage,
        data: FormData.fromMap(
          {
            'conversation_id': conversationId,
            'file': await MultipartFile.fromFile(file.path),
          },
        ),
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
