import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/dashboard_request_model.dart';
import '../model/dashboard_response_model.dart';

abstract interface class DashboardRepository {
  Future<Either<ServerFailure, DashboardResponseModel>> getProfileDashboard({
    DashboardRequestModel request,
  });
}
