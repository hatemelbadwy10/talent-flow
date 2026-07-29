sealed class FreelancerProfileEvent {
  const FreelancerProfileEvent();
}

final class FreelancerProfileRequested extends FreelancerProfileEvent {
  const FreelancerProfileRequested(this.id);

  final int id;
}
