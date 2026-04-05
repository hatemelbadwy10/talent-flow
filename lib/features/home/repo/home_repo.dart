import 'package:dartz/dartz.dart';
import 'package:talent_flow/data/api/end_points.dart';
import 'package:talent_flow/data/api/response_payload_parser.dart';
import 'package:talent_flow/data/error/api_error_handler.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/error/failures.dart';
import '../model/entrepreneur_profile_model.dart';
import '../model/freelancer_profile_model.dart';
import '../model/freelancers_model.dart';
import '../model/home_model.dart';
import '../model/work_details_model.dart';

class HomeRepo extends BaseRepo {
  HomeRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, HomeModel>> getHome() async {
    try {
      final response = await dioClient.get(uri: EndPoints.home);
      final payload = ResponsePayloadParser.payloadMap(response.data);
      return Right(HomeModel.fromJson(payload));
    } catch (error) {
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, List<Category>>> getCategories() async {
    try {
      final response = await dioClient.get(uri: EndPoints.categories);
      final payload = ResponsePayloadParser.payloadList(response.data);
      final categories = payload
          .map((item) => Category.fromJson(ResponsePayloadParser.map(item)))
          .toList();
      return Right(categories);
    } catch (error) {
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, List<FreelancersModel>>> getFreelancers({
    int? categoryId,
  }) async {
    try {
      final uri = categoryId != null
          ? "${EndPoints.subCategories}$categoryId"
          : EndPoints.freelancers;

      final response = await dioClient.get(uri: uri);
      final payload = ResponsePayloadParser.payload(response.data);
      final rawItems = categoryId == null
          ? ResponsePayloadParser.list(payload)
          : ResponsePayloadParser.list(
              ResponsePayloadParser.map(payload)['items'],
            );
      final freelancers = rawItems
          .map(
            (item) =>
                FreelancersModel.fromJson(ResponsePayloadParser.map(item)),
          )
          .toList();
      return Right(freelancers);
    } catch (error) {
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, FreelancerProfileModel>> getFreelancerProfile(
    int id,
  ) async {
    try {
      final response =
          await dioClient.get(uri: "${EndPoints.freelancerDetails}$id");
      final payload = ResponsePayloadParser.payloadMap(response.data);
      return Right(FreelancerProfileModel.fromJson(payload));
    } catch (error) {
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, EntrepreneurProfileModel>>
      getEntrepreneurProfile(int id) async {
    try {
      final response =
          await dioClient.get(uri: "${EndPoints.entrepreneurDetails}$id");
      final payload = ResponsePayloadParser.payloadMap(response.data);
      return Right(EntrepreneurProfileModel.fromJson(payload));
    } catch (error) {
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<ServerFailure, WorkDetailsModel>> getWorkDetails(int id) async {
    try {
      final response = await dioClient.get(uri: EndPoints.workDetails(id));
      final payload = ResponsePayloadParser.payloadMap(response.data);
      return Right(WorkDetailsModel.fromJson(payload));
    } catch (error) {
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
