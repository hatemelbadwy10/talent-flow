import '../model/freelancer_profile_model.dart';

sealed class FreelancerProfileState {
  const FreelancerProfileState();
}

final class FreelancerProfileInitial extends FreelancerProfileState {
  const FreelancerProfileInitial();
}

final class FreelancerProfileLoading extends FreelancerProfileState {
  const FreelancerProfileLoading();
}

final class FreelancerProfileLoaded extends FreelancerProfileState {
  const FreelancerProfileLoaded(this.profile);

  final FreelancerProfileModel profile;
}

final class FreelancerProfileFailed extends FreelancerProfileState {
  const FreelancerProfileFailed(this.message);

  final String message;
}
