import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/identity_verification_details.dart';
import '../model/identity_verification_request.dart';

abstract interface class IdentityVerificationRepository {
  Future<Either<ServerFailure, String>> submitIdentityVerification(
    IdentityVerificationRequest request,
  );
  Future<Either<ServerFailure, IdentityVerificationDetails?>>
      getIdentityVerification();
}
