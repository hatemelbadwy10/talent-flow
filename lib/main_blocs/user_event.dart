import '../main_models/user_model.dart';

sealed class UserEvent {
  const UserEvent();
}

class LoadCurrentUser extends UserEvent {
  const LoadCurrentUser();
}

class UpdateCurrentUser extends UserEvent {
  const UpdateCurrentUser(this.user);

  final UserModel user;
}

class ClearCurrentUser extends UserEvent {
  const ClearCurrentUser();
}
