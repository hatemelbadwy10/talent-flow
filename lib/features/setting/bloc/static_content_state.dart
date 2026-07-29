sealed class StaticContentState {
  const StaticContentState();
}

final class StaticContentInitial extends StaticContentState {
  const StaticContentInitial();
}

final class StaticContentLoading extends StaticContentState {
  const StaticContentLoading();
}

final class StaticContentLoaded extends StaticContentState {
  const StaticContentLoaded(this.html);
  final String html;
}

final class StaticContentFailed extends StaticContentState {
  const StaticContentFailed(this.message);
  final String message;
}
