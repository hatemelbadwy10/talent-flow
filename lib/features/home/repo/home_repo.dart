import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:talent_flow/data/api/end_points.dart';
import 'package:talent_flow/main_repos/base_repo.dart';

import '../../../data/error/failures.dart';
import '../model/home_model.dart';
import '../model/freelancers_model.dart';
import '../model/freelancer_profile_model.dart';
import 'home_dashboard_repository.dart';
import 'categories_repository.dart';
import 'freelancers_repository.dart';
import 'freelancer_profile_repository.dart';

class HomeRepo extends BaseRepo
    implements
        HomeDashboardRepository,
        CategoriesRepository,
        FreelancersRepository,
        FreelancerProfileRepository {
  HomeRepo({required super.sharedPreferences, required super.dioClient});

  Future<Either<ServerFailure, Response>> getHome() async {
    try {
      final response = await dioClient.get(uri: EndPoints.home);
      return Right(response);
    } on DioException catch (e) {
      return Left(
          ServerFailure(e.message ?? 'An unexpected Dio error occurred'));
    } catch (e) {
      // Catch any other general errors
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<ServerFailure, HomeModel>> getDashboard() async {
    try {
      final response = await dioClient.get(uri: EndPoints.home);
      final data = Map<String, dynamic>.from(response.data as Map);
      final payload = data['payload'];
      if (payload is! Map) {
        return left(ServerFailure('Home payload is invalid'));
      }
      return right(
        HomeModel.fromJson(Map<String, dynamic>.from(payload)),
      );
    } on DioException catch (error) {
      return left(
        ServerFailure(error.message ?? 'An unexpected Dio error occurred'),
      );
    } on FormatException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  Future<Either<ServerFailure, Response>> getCategories() async {
    try {
      final response = await dioClient.get(uri: EndPoints.categories);
      return Right(response); // If successful, wrap the response in a Right
    } on DioException catch (e) {
      // Catch Dio-specific errors
      return Left(
          ServerFailure(e.message ?? 'An unexpected Dio error occurred'));
    } catch (e) {
      // Catch any other general errors
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<ServerFailure, List<Category>>> getCategoryList() async {
    try {
      final response = await dioClient.get(uri: EndPoints.categories);
      final data = Map<String, dynamic>.from(response.data as Map);
      final payload = data['payload'];
      if (payload is! List) {
        return left(ServerFailure('Categories payload is invalid'));
      }
      return right(
        payload
            .map((item) => Category.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(growable: false),
      );
    } on DioException catch (error) {
      return left(
        ServerFailure(error.message ?? 'An unexpected Dio error occurred'),
      );
    } on FormatException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  Future<Either<ServerFailure, Response>> getFreelancers({
    int? categoryId,
    String? search,
  }) async {
    try {
      final uri = categoryId != null
          ? "${EndPoints.subCategories}$categoryId" // api/categories/{id}
          : EndPoints.freelancers; // الحالة العادية
      final queryParameters = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }

      final response = await dioClient.get(
        uri: uri,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(
          ServerFailure(e.message ?? 'An unexpected Dio error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<ServerFailure, List<FreelancersModel>>> getFreelancerList({
    int? categoryId,
    String? search,
  }) async {
    try {
      final uri = categoryId == null
          ? EndPoints.freelancers
          : '${EndPoints.subCategories}$categoryId';
      final normalizedSearch = search?.trim() ?? '';
      final response = await dioClient.get(
        uri: uri,
        queryParameters:
            normalizedSearch.isEmpty ? null : {'search': normalizedSearch},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final rootPayload = data['payload'];
      final payload = categoryId == null
          ? rootPayload
          : rootPayload is Map
              ? rootPayload['items']
              : null;
      if (payload is! List) {
        return left(ServerFailure('Freelancers payload is invalid'));
      }
      return right(
        payload
            .map((item) => FreelancersModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(growable: false),
      );
    } on DioException catch (error) {
      return left(
        ServerFailure(error.message ?? 'An unexpected Dio error occurred'),
      );
    } on FormatException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  Future<Either<ServerFailure, Response>> getFreelancerProfile(int id) async {
    try {
      final response =
          await dioClient.get(uri: "${EndPoints.freelancerDetails}$id");
      return Right(response);
    } on DioException catch (e) {
      return Left(
          ServerFailure(e.message ?? 'An unexpected Dio error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<ServerFailure, FreelancerProfileModel>> getProfile(
    int id,
  ) async {
    try {
      final response =
          await dioClient.get(uri: '${EndPoints.freelancerDetails}$id');
      final data = Map<String, dynamic>.from(response.data as Map);
      final payload = data['payload'];
      if (payload is! Map) {
        return left(ServerFailure('Freelancer profile payload is invalid'));
      }
      return right(
        FreelancerProfileModel.fromJson(
          Map<String, dynamic>.from(payload),
        ),
      );
    } on DioException catch (error) {
      return left(
        ServerFailure(error.message ?? 'An unexpected Dio error occurred'),
      );
    } on FormatException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  Future<Either<ServerFailure, Response>> getEntrepreneurProfile(int id) async {
    try {
      final response =
          await dioClient.get(uri: "${EndPoints.entrepreneurDetails}$id");
      return Right(response);
    } on DioException catch (e) {
      return Left(
          ServerFailure(e.message ?? 'An unexpected Dio error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<ServerFailure, Response>> getWorkDetails(int id) async {
    try {
      final response = await dioClient.get(uri: EndPoints.workDetails(id));
      return Right(response);
    } on DioException catch (e) {
      return Left(
          ServerFailure(e.message ?? 'An unexpected Dio error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
