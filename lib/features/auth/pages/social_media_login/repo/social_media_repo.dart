import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../data/api/end_points.dart';
import '../../../../../data/error/api_error_handler.dart';
import '../../../../../data/error/failures.dart';
import '../../../../../helpers/social_media_login_helper.dart';
import '../../../../../main_repos/base_repo.dart';
import '../../../models/auth_response.dart';
import 'social_media_repository.dart';

class SocialMediaRepo extends BaseRepo implements SocialMediaRepository {
  SocialMediaRepo({
    required this.socialMediaLoginHelper,
    required super.sharedPreferences,
    required super.dioClient,
  });

  final SocialMediaLoginHelper socialMediaLoginHelper;

  @override
  Future<Either<ServerFailure, AuthResponse>> signInWithSocialMedia({
    required SocialMediaProvider provider,
    required bool isFreelancer,
  }) async {
    try {
      Either<ServerFailure, SocialMediaModel>? socialResponse;
      if (provider == SocialMediaProvider.google) {
        socialResponse = await socialMediaLoginHelper.googleLogin();
      }
      if (provider == SocialMediaProvider.apple) {
        socialResponse = await socialMediaLoginHelper.appleLogin();
      }
      if (socialResponse == null) {
        return left(ServerFailure('Unsupported social provider'));
      }

      return socialResponse.fold(
        left,
        (socialAccount) async {
          final idToken = socialAccount.idToken;
          if (idToken == null || idToken.isEmpty) {
            return left(
              ServerFailure('Authentication failed: No valid token'),
            );
          }

          try {
            final response = await dioClient.post(
              uri: EndPoints.socialMediaAuth,
              data: {
                'token': idToken,
                'provider': provider.name,
                'user_type': isFreelancer ? 'Freelancer' : 'Entrepreneur',
              },
            );
            final data = response.data;
            if (response.statusCode == 200 && data is Map) {
              return right(
                AuthResponse.fromJson(Map<String, dynamic>.from(data)),
              );
            }
            final message = data is Map ? data['message']?.toString() : null;
            return left(
              ServerFailure(
                message ?? 'Social login failed',
                statusCode: response.statusCode,
              ),
            );
          } catch (error) {
            if (error is DioException && error.response != null) {
              final responseData = error.response!.data;
              final message = responseData is Map
                  ? responseData['message']?.toString()
                  : null;
              return left(
                ServerFailure(
                  message ?? ApiErrorHandler.getServerFailure(error).error,
                  statusCode: error.response!.statusCode,
                ),
              );
            }
            return left(ApiErrorHandler.getServerFailure(error));
          }
        },
      );
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
