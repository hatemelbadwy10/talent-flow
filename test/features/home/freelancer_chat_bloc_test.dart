import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/data/realtime/realtime_chat_service.dart';
import 'package:talent_flow/features/home/bloc/freelancer_chat_bloc.dart';
import 'package:talent_flow/features/home/model/chat_model.dart';
import 'package:talent_flow/features/home/repo/chat_repository.dart';

void main() {
  group('FreelancerChatBloc', () {
    test('loads a typed conversation and subscribes to its channel', () async {
      final realtime = _FakeRealtimeChatService();
      final repository = _FakeChatRepository();
      final bloc = FreelancerChatBloc(
        repository: repository,
        realtimeService: realtime,
      );

      bloc.add(const ConversationRequested(conversationId: 12));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<FreelancerChatLoading>(),
          isA<FreelancerChatLoaded>(),
        ]),
      );

      expect(repository.loadedConversationId, 12);
      expect(realtime.subscribedChannel, 'private-chat.12');
      await bloc.close();
    });

    test('emits a typed failure when loading fails', () async {
      final bloc = FreelancerChatBloc(
        repository: _FakeChatRepository(fail: true),
        realtimeService: _FakeRealtimeChatService(),
      );

      bloc.add(const ConversationRequested(conversationId: 12));
      final state = await bloc.stream.firstWhere(
        (state) => state is FreelancerChatFailed,
      ) as FreelancerChatFailed;

      expect(state.message, 'Could not load conversation');
      await bloc.close();
    });
  });
}

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository({this.fail = false});

  final bool fail;
  int? loadedConversationId;

  @override
  Future<Either<ServerFailure, ChatModel>> getConversationMessages(
    int conversationId, {
    String? search,
  }) async {
    loadedConversationId = conversationId;
    if (fail) {
      return left(ServerFailure('Could not load conversation'));
    }
    return right(
      ChatModel(
        id: conversationId,
        projectId: null,
        contractId: null,
        hasContract: false,
        receiver: null,
        messages: const [],
      ),
    );
  }

  @override
  Future<Either<ServerFailure, Message?>> sendConversationFileMessage({
    required int conversationId,
    required File file,
  }) async =>
      right(null);

  @override
  Future<Either<ServerFailure, Message?>> sendConversationMessage({
    required int conversationId,
    required String body,
  }) async =>
      right(null);

  @override
  Future<Either<ServerFailure, int>> startConversation({
    required int userId,
    int? projectId,
  }) async =>
      right(1);
}

class _FakeRealtimeChatService implements RealtimeChatService {
  String? subscribedChannel;

  @override
  String chatChannel(int conversationId) => 'private-chat.$conversationId';

  @override
  Future<void> subscribe({
    required String channelName,
    required void Function(RealtimeEvent event) onEvent,
  }) async {
    subscribedChannel = channelName;
  }

  @override
  Future<void> unsubscribe(String channelName) async {}
}
