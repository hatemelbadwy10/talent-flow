import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';

abstract interface class TermsRepository {
  Future<Either<ServerFailure, String>> getTermsAndCondition();
}
