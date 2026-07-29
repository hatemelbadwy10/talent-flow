sealed class SettingsState {
  const SettingsState();
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class HelpSubmissionSucceeded extends SettingsState {
  const HelpSubmissionSucceeded(this.message);
  final String message;
}

final class LogoutSucceeded extends SettingsState {
  const LogoutSucceeded(this.message);
  final String message;
}

final class AccountDeletionSucceeded extends SettingsState {
  const AccountDeletionSucceeded(this.message);
  final String message;
}

final class SettingsFailed extends SettingsState {
  const SettingsFailed(this.message);
  final String message;
}
