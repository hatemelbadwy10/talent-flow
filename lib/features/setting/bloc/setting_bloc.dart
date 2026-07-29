import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/auth_session_store.dart';
import '../repo/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required SettingsRepository repository,
    required AuthSessionStore sessionStore,
  })  : _repository = repository,
        _sessionStore = sessionStore,
        super(const SettingsInitial()) {
    on<HelpSubmitted>(_onHelp);
    on<LogoutRequested>(_onLogout);
    on<AccountDeletionRequested>(_onDeleteAccount);
  }

  final SettingsRepository _repository;
  final AuthSessionStore _sessionStore;

  Future<void> _onHelp(
    HelpSubmitted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await _repository.help(event.request);
    result.fold(
      (failure) => emit(SettingsFailed(failure.error)),
      (message) => emit(HelpSubmissionSucceeded(message)),
    );
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await _repository.logout();
    await result.fold(
      (failure) async => emit(SettingsFailed(failure.error)),
      (message) async {
        await _sessionStore.clearAuthenticatedSession();
        emit(LogoutSucceeded(message));
      },
    );
  }

  Future<void> _onDeleteAccount(
    AccountDeletionRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await _repository.deleteAccount();
    await result.fold(
      (failure) async => emit(SettingsFailed(failure.error)),
      (message) async {
        await _sessionStore.clearAuthenticatedSession();
        emit(AccountDeletionSucceeded(message));
      },
    );
  }
}
