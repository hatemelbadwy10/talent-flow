import '../../../../../helpers/social_media_login_helper.dart';

sealed class SocialMediaEvent {
  const SocialMediaEvent();
}

final class SocialSignInRequested extends SocialMediaEvent {
  const SocialSignInRequested(this.provider);
  final SocialMediaProvider provider;
}
