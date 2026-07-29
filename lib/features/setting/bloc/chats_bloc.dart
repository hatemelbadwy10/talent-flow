import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/chats_model.dart';
import '../repo/chats_repository.dart';

sealed class ChatsEvent {
  const ChatsEvent();
}

final class ChatsRequested extends ChatsEvent {
  const ChatsRequested({this.projectId});

  final int? projectId;
}

final class ChatProjectOptionsRequested extends ChatsEvent {
  const ChatProjectOptionsRequested();
}

final class ConversationMarkedRead extends ChatsEvent {
  const ConversationMarkedRead(this.conversationId);

  final int conversationId;
}

sealed class ChatsState {
  const ChatsState({
    this.chats = const [],
    this.projectOptions = const {},
  });

  final List<ChatsModel> chats;
  final Map<int, String> projectOptions;
}

final class ChatsInitial extends ChatsState {
  const ChatsInitial();
}

final class ChatsLoading extends ChatsState {
  const ChatsLoading({
    required super.chats,
    required super.projectOptions,
  });
}

final class ChatsLoaded extends ChatsState {
  const ChatsLoaded({
    required super.chats,
    required super.projectOptions,
  });
}

final class ChatsFailed extends ChatsState {
  const ChatsFailed({
    required this.message,
    required super.chats,
    required super.projectOptions,
  });

  final String message;
}

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc({required ChatsRepository repository})
      : _repository = repository,
        super(const ChatsInitial()) {
    on<ChatsRequested>(_onChatsRequested);
    on<ChatProjectOptionsRequested>(_onProjectOptionsRequested);
    on<ConversationMarkedRead>(_onConversationMarkedRead);
  }

  final ChatsRepository _repository;

  Future<void> _onProjectOptionsRequested(
    ChatProjectOptionsRequested event,
    Emitter<ChatsState> emit,
  ) async {
    final result = await _repository.getProjectChatOptions();
    result.fold(
      (failure) => emit(
        ChatsFailed(
          message: failure.error,
          chats: state.chats,
          projectOptions: state.projectOptions,
        ),
      ),
      (options) => emit(
        ChatsLoaded(chats: state.chats, projectOptions: options),
      ),
    );
  }

  Future<void> _onChatsRequested(
    ChatsRequested event,
    Emitter<ChatsState> emit,
  ) async {
    emit(
      ChatsLoading(
        chats: state.chats,
        projectOptions: state.projectOptions,
      ),
    );
    final result = await _repository.getChats(projectId: event.projectId);
    result.fold(
      (failure) => emit(
        ChatsFailed(
          message: failure.error,
          chats: state.chats,
          projectOptions: state.projectOptions,
        ),
      ),
      (chats) => emit(
        ChatsLoaded(chats: chats, projectOptions: state.projectOptions),
      ),
    );
  }

  void _onConversationMarkedRead(
    ConversationMarkedRead event,
    Emitter<ChatsState> emit,
  ) {
    var changed = false;
    final chats = state.chats.map((chat) {
      if (chat.id != event.conversationId || (chat.unreadCount ?? 0) == 0) {
        return chat;
      }
      changed = true;
      return chat.copyWith(unreadCount: 0);
    }).toList();
    if (changed) {
      emit(ChatsLoaded(chats: chats, projectOptions: state.projectOptions));
    }
  }
}
