sealed class SocialMediaState {
  const SocialMediaState();
}

final class SocialMediaInitial extends SocialMediaState {
  const SocialMediaInitial();
}

final class SocialMediaLoading extends SocialMediaState {
  const SocialMediaLoading();
}

final class SocialMediaSucceeded extends SocialMediaState {
  const SocialMediaSucceeded();
}

final class SocialMediaFailed extends SocialMediaState {
  const SocialMediaFailed(this.message);
  final String message;
}
