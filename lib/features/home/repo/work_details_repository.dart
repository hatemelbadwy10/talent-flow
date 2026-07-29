import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/work_details_model.dart';

abstract interface class WorkDetailsRepository {
  Future<Either<ServerFailure, WorkDetailsModel>> getWork(int id);
}
