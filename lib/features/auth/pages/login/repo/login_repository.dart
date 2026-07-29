import 'package:dartz/dartz.dart';

import '../../../../../data/error/failures.dart';
import '../../../models/auth_response.dart';

abstract interface class LoginRepository {
  Future<Either<ServerFailure, AuthResponse>> logIn({
    required String email,
    required String password,
  });

  Future<Either<ServerFailure, Unit>> resendVerificationEmail(String email);
}
