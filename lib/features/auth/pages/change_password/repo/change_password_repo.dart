import 'package:dartz/dartz.dart';

import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../main_repos/base_repo.dart';
import 'change_password_repository.dart';

class ChangePasswordRepo extends BaseRepo implements ChangePasswordRepository {
  ChangePasswordRepo(
      {required super.sharedPreferences, required super.dioClient});

  @override
  Future<Either<ServerFailure, String>> changePassword({
    required String identifier,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dioClient.post(
        uri: EndPoints.changePassword,
        data: {
          'identifier': identifier,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return Right(
          data is Map ? data['message']?.toString() ?? '' : '',
        );
      } else {
        return Left(ServerFailure(response.data['message']));
      }
    } catch (error) {
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
