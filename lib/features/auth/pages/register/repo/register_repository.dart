import 'package:dartz/dartz.dart';

import '../../../../../data/error/failures.dart';
import '../model/register_request.dart';

abstract interface class RegisterRepository {
  Future<Either<ServerFailure, Unit>> register(RegisterRequest request);
}
