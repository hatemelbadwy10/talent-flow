import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/freelancers_model.dart';

abstract interface class FreelancersRepository {
  Future<Either<ServerFailure, List<FreelancersModel>>> getFreelancerList({
    int? categoryId,
    String? search,
  });
}
