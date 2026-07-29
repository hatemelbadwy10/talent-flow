import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/entrepreneur_profile_model.dart';

abstract interface class EntrepreneurProfileRepository {
  Future<Either<ServerFailure, EntrepreneurProfileModel>> getEntrepreneur(
    int id,
  );
}
