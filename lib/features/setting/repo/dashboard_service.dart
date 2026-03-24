import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/dio/dio_client.dart';
import '../model/dashboard_request_model.dart';

class DashboardService {
  DashboardService({required DioClient dioClient}) : _dioClient = dioClient;

  final DioClient _dioClient;

  Future<Response> getProfileDashboard(DashboardRequestModel request) {
    return _dioClient.get(
      uri: EndPoints.profileDashboard,
      queryParameters: request.toQueryParameters(),
    );
  }
}
