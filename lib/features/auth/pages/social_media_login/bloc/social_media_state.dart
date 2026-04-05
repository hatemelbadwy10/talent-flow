import 'package:equatable/equatable.dart';

abstract class SocialMediaState extends Equatable {
  const SocialMediaState();

  @override
  List<Object?> get props => [];
}

class SocialMediaInitial extends SocialMediaState {
  const SocialMediaInitial();
}

class SocialMediaInProgress extends SocialMediaState {
  const SocialMediaInProgress();
}

class SocialMediaFailure extends SocialMediaState {
  const SocialMediaFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class SocialMediaSuccess extends SocialMediaState {
  const SocialMediaSuccess();
}
