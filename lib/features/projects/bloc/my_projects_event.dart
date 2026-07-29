sealed class MyProjectsEvent {
  const MyProjectsEvent();
}

final class MyProjectsRequested extends MyProjectsEvent {
  const MyProjectsRequested({this.status, this.categoryId});

  final String? status;
  final int? categoryId;
}
