import '../model/help_model.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

final class HelpSubmitted extends SettingsEvent {
  const HelpSubmitted(this.request);
  final HelpModel request;
}

final class LogoutRequested extends SettingsEvent {
  const LogoutRequested();
}

final class AccountDeletionRequested extends SettingsEvent {
  const AccountDeletionRequested();
}
