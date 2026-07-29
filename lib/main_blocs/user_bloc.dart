import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/config/di.dart';
import '../data/realtime/user_subscription_controller.dart';
import '../main_models/user_model.dart';
import '../main_repos/user_repository.dart';

sealed class UserEvent {
  const UserEvent();
}

final class UserRequested extends UserEvent {
  const UserRequested();
}

final class UserModelUpdated extends UserEvent {
  const UserModelUpdated(this.user);

  final UserModel user;
}

final class UserPayloadUpdated extends UserEvent {
  const UserPayloadUpdated(this.payload);

  final Map<String, dynamic> payload;
}

final class UserUnreadCountsSynced extends UserEvent {
  const UserUnreadCountsSynced({
    this.notifications,
    this.messages,
  });

  final int? notifications;
  final int? messages;
}

final class UserCleared extends UserEvent {
  const UserCleared();
}

sealed class UserState {
  const UserState({this.user});

  final UserModel? user;
}

final class UserInitial extends UserState {
  const UserInitial();
}

final class UserLoading extends UserState {
  const UserLoading({super.user});
}

final class UserLoaded extends UserState {
  const UserLoaded(UserModel user) : super(user: user);
}

final class UserFailed extends UserState {
  const UserFailed(this.message);

  final String message;
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({
    required UserRepository repository,
    required UserSubscriptionController subscriptionController,
  })  : _repository = repository,
        _subscriptionController = subscriptionController,
        super(const UserInitial()) {
    on<UserRequested>(_onRequested);
    on<UserModelUpdated>(_onModelUpdated);
    on<UserPayloadUpdated>(_onPayloadUpdated);
    on<UserUnreadCountsSynced>(_onUnreadCountsSynced);
    on<UserCleared>(_onCleared);
  }

  final UserRepository _repository;
  final UserSubscriptionController _subscriptionController;

  static UserBloc get instance => sl<UserBloc>();

  bool get isLogin => _repository.isLogIn;
  UserModel? get user => state.user;

  Future<void> _onRequested(
    UserRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading(user: state.user));
    var response = _repository.isLogIn
        ? await _repository.fetchUserProfile()
        : _repository.getUser();
    if (response.isLeft()) {
      final localResponse = _repository.getUser();
      if (localResponse.isRight()) {
        response = localResponse;
      }
    }
    response.fold(
      (failure) => emit(UserFailed(failure.error)),
      (user) => emit(UserLoaded(user)),
    );
  }

  Future<void> _onModelUpdated(
    UserModelUpdated event,
    Emitter<UserState> emit,
  ) async {
    await _repository.setUserData(event.user.toJson());
    emit(UserLoaded(event.user));
  }

  Future<void> _onPayloadUpdated(
    UserPayloadUpdated event,
    Emitter<UserState> emit,
  ) async {
    await _repository.setUserData(event.payload);
    emit(UserLoaded(UserModel.fromJson(event.payload)));
  }

  void _onUnreadCountsSynced(
    UserUnreadCountsSynced event,
    Emitter<UserState> emit,
  ) {
    final user = _repository.updateUnreadCounts(
      notifications: event.notifications,
      messages: event.messages,
    );
    if (user != null) {
      emit(UserLoaded(user));
    }
  }

  Future<void> _onCleared(
    UserCleared event,
    Emitter<UserState> emit,
  ) async {
    await _subscriptionController.clearSubscription();
    await _repository.clearUserData();
    emit(const UserInitial());
  }
}

enum UserType { company, talent }
