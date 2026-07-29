import '../model/freelancers_model.dart';

sealed class FreelancersState {
  const FreelancersState();
}

final class FreelancersInitial extends FreelancersState {
  const FreelancersInitial();
}

final class FreelancersLoading extends FreelancersState {
  const FreelancersLoading();
}

final class FreelancersLoaded extends FreelancersState {
  const FreelancersLoaded(this.freelancers);

  final List<FreelancersModel> freelancers;
}

final class FreelancersFailed extends FreelancersState {
  const FreelancersFailed(this.message);

  final String message;
}
