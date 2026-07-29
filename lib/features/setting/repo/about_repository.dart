import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';

abstract interface class AboutRepository {
  Future<Either<ServerFailure, String>> getAboutContent();
}
