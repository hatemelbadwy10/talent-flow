import 'package:dartz/dartz.dart';

import '../../../../../data/error/failures.dart';
import '../../../../../helpers/social_media_login_helper.dart';
import '../../../models/auth_response.dart';

abstract interface class SocialMediaRepository {
  Future<Either<ServerFailure, AuthResponse>> signInWithSocialMedia({
    required SocialMediaProvider provider,
    required bool isFreelancer,
  });
}
