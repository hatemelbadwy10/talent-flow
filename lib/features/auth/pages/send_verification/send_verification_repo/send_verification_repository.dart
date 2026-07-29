import 'package:dartz/dartz.dart';

import '../../../../../data/error/failures.dart';
import '../model/send_verification_result.dart';

abstract interface class SendVerificationRepository {
  Future<Either<ServerFailure, SendVerificationResult>> sendVerification(
    String identifier,
  );
}
