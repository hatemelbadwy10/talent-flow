import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../../projects/model/my_projects_model.dart';

abstract interface class NewProjectsRepository {
  Future<Either<ServerFailure, List<MyProjectsModel>>> getProjectFeed({
    int? specializationId,
    String? sortBy,
    String? search,
  });

  Future<Either<ServerFailure, String>> submitOffer({
    required int projectId,
    required String description,
    required List<Map<String, dynamic>> answers,
    int? proposalId,
  });

  Future<Either<ServerFailure, String>> toggleProjectFavorite(int projectId);
}
