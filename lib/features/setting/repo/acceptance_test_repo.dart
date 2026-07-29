import 'package:dartz/dartz.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../model/acceptance_test_content.dart';
import 'acceptance_test_repository.dart';

class AcceptanceTestRepo extends BaseRepo implements AcceptanceTestRepository {
  AcceptanceTestRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  @override
  Future<Either<ServerFailure, AcceptanceTestContent>>
      getAcceptanceTestQuestions() async {
    try {
      final response =
          await dioClient.get(uri: EndPoints.acceptanceTestQuestions);
      final data = response.data;
      final map = data is Map
          ? data.map((key, value) => MapEntry(key.toString(), value))
          : null;
      return Right(
        AcceptanceTestContent.fromPayload(map?['payload'] ?? map ?? data),
      );
    } catch (error) {
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
