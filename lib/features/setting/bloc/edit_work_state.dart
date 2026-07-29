sealed class EditWorkState {
  const EditWorkState();
}

final class EditWorkInitial extends EditWorkState {
  const EditWorkInitial();
}

final class EditWorkSubmitting extends EditWorkState {
  const EditWorkSubmitting();
}

final class EditWorkSucceeded extends EditWorkState {
  const EditWorkSucceeded(this.action);
  final EditWorkAction action;
}

enum EditWorkAction { updated, deleted }

final class EditWorkFailed extends EditWorkState {
  const EditWorkFailed(this.message);
  final String message;
}
