import '../model/edit_work_request_model.dart';

sealed class EditWorkEvent {
  const EditWorkEvent();
}

final class WorkUpdateSubmitted extends EditWorkEvent {
  const WorkUpdateSubmitted(this.request);
  final EditWorkRequestModel request;
}

final class WorkDeleteSubmitted extends EditWorkEvent {
  const WorkDeleteSubmitted(this.workId);
  final int workId;
}
