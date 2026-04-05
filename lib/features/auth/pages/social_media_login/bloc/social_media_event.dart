import 'package:equatable/equatable.dart';
import '../../../../../helpers/social_media_login_helper.dart';

class SocialMediaEvent extends Equatable {
  const SocialMediaEvent();

  @override
  List<Object?> get props => [];
}

class SocialProviderAuthenticationRequested extends SocialMediaEvent {
  const SocialProviderAuthenticationRequested(this.provider);

  final SocialMediaProvider provider;

  @override
  List<Object?> get props => [provider];
}
