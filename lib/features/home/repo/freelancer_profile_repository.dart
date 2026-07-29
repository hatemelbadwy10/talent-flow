import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/freelancer_profile_model.dart';

abstract interface class FreelancerProfileRepository {
  Future<Either<ServerFailure, FreelancerProfileModel>> getProfile(int id);
}
