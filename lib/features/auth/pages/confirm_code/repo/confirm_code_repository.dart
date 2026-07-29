import 'package:dartz/dartz.dart';

import '../../../../../data/error/failures.dart';
import '../model/confirm_code_request.dart';
import '../model/confirm_code_result.dart';

abstract interface class ConfirmCodeRepository {
  Future<Either<ServerFailure, ConfirmCodeResult>> confirm(
    ConfirmCodeRequest request,
  );
}
