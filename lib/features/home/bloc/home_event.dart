sealed class HomeEvent {
  const HomeEvent();
}

class HomeRequested extends HomeEvent {
  const HomeRequested();
}

class HomeCategoriesRequested extends HomeEvent {
  const HomeCategoriesRequested();
}

class HomeFreelancersRequested extends HomeEvent {
  const HomeFreelancersRequested({this.categoryId});

  final int? categoryId;
}

class FreelancerProfileRequested extends HomeEvent {
  const FreelancerProfileRequested(this.freelancerId);

  final int freelancerId;
}

class EntrepreneurProfileRequested extends HomeEvent {
  const EntrepreneurProfileRequested(this.entrepreneurId);

  final int entrepreneurId;
}

class WorkDetailsRequested extends HomeEvent {
  const WorkDetailsRequested(this.workId);

  final int workId;
}
