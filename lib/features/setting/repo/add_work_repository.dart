import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/work_item.dart';

abstract interface class AddWorkRepository {
  Future<Either<ServerFailure, String>> addWork({
    required WorkItem work,
  });

  Future<Either<ServerFailure, String>> addWorks({
    required List<WorkItem> works,
    Map<String, String>? answers,
  });
}
