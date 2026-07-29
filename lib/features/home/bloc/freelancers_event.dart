sealed class FreelancersEvent {
  const FreelancersEvent();
}

final class FreelancersRequested extends FreelancersEvent {
  const FreelancersRequested({this.categoryId, this.search});

  final int? categoryId;
  final String? search;
}
