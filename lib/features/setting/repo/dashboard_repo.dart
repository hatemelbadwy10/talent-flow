import 'package:dartz/dartz.dart';

import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../model/dashboard_request_model.dart';
import '../model/dashboard_response_model.dart';
import 'dashboard_service.dart';

class DashboardRepo extends BaseRepo {
  DashboardRepo({
    required super.sharedPreferences,
    required super.dioClient,
  }) : _service = DashboardService(dioClient: dioClient);

  final DashboardService _service;

  Future<Either<ServerFailure, DashboardResponseModel>> getProfileDashboard({
    DashboardRequestModel request = const DashboardRequestModel(),
  }) async {
    try {
      final response = await _service.getProfileDashboard(request);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return Right(DashboardResponseModel.fromJson(body));
      }

      if (body is Map) {
        return Right(
          DashboardResponseModel.fromJson(Map<String, dynamic>.from(body)),
        );
      }

      return const Right(
        DashboardResponseModel(
          statuses: [],
          recentProjects: [],
          rawPayload: {},
        ),
      );
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
