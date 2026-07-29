import 'package:dartz/dartz.dart';

import '../../../../../data/error/failures.dart';

abstract interface class ChangePasswordRepository {
  Future<Either<ServerFailure, String>> changePassword({
    required String identifier,
    required String password,
    required String passwordConfirmation,
  });
}
