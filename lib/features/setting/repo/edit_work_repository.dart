import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/edit_work_request_model.dart';

abstract interface class EditWorkRepository {
  Future<Either<ServerFailure, String>> updateWork({
    required EditWorkRequestModel request,
  });
  Future<Either<ServerFailure, String>> deleteWork(int id);
}
