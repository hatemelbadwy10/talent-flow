import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class ChatsRepo extends BaseRepo {
  ChatsRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> getChats({
    String search = '',
    int? projectId,
  }) async {
    try {
      final encodedSearch = Uri.encodeQueryComponent(search);
      final projectIdValue = projectId?.toString() ?? '';
      final response = await dioClient.get(
        uri:
            '${EndPoints.conversations}?search=$encodedSearch&project_id=$projectIdValue',
      );
      return Right(response);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
