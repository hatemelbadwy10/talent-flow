import 'package:dartz/dartz.dart';

import '../../../data/api/end_points.dart';
import '../../../data/api/response_payload_parser.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../../projects/model/my_projects_model.dart';

class NewProjectsRepo extends BaseRepo {
  NewProjectsRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, List<MyProjectsModel>>> getProjects() async {
    try {
      final response = await dioClient.get(uri: EndPoints.projects);
      final payload = ResponsePayloadParser.payloadList(response.data);
      return Right(
        payload
            .map((item) =>
                MyProjectsModel.fromJson(ResponsePayloadParser.map(item)))
            .toList(),
      );
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, String?>> addOffer(int id, String offer) async {
    try {
      final response = await dioClient.post(
          uri: EndPoints.addOffer,
          queryParameters: {"project_id": id, "description": offer});
      final responseData = ResponsePayloadParser.map(response.data);
      return Right(responseData['message']?.toString());
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, String?>> addRemoveFavorite(int id) async {
    try {
      final response =
          await dioClient.get(uri: "${EndPoints.projects}/$id/favourite");
      final responseData = ResponsePayloadParser.map(response.data);
      return Right(responseData['message']?.toString());
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
