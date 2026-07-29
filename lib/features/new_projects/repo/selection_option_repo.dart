import 'package:dartz/dartz.dart';
import 'package:talent_flow/features/new_projects/model/selection_option_model.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import 'selection_options_repository.dart';

class SelectionOptionRepo extends BaseRepo
    implements SelectionOptionsRepository {
  SelectionOptionRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  @override
  Future<Either<ServerFailure, SelectionModel>> getSelectionOptions() async {
    try {
      final response = await dioClient.get(uri: EndPoints.selectionOption);
      final data = Map<String, dynamic>.from(response.data as Map);
      final payload = Map<String, dynamic>.from(data['payload'] as Map);
      return Right(SelectionModel.fromJson(payload));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
