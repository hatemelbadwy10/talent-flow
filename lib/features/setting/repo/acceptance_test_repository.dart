import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/acceptance_test_content.dart';

abstract interface class AcceptanceTestRepository {
  Future<Either<ServerFailure, AcceptanceTestContent>>
      getAcceptanceTestQuestions();
}
