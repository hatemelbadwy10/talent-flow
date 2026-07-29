import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/chats_bloc.dart';
import 'package:talent_flow/features/setting/model/chats_model.dart';
import 'package:talent_flow/features/setting/repo/chats_repository.dart';

void main() {
  group('ChatsBloc', () {
    test('forwards the project filter and emits typed conversations', () async {
      final repository = _FakeChatsRepository();
      final bloc = ChatsBloc(repository: repository);

      bloc.add(const ChatsRequested(projectId: 42));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ChatsLoading>(),
          isA<ChatsLoaded>(),
        ]),
      );

      expect(repository.projectId, 42);
      await bloc.close();
    });

    test('loads typed project filter options', () async {
      final bloc = ChatsBloc(repository: _FakeChatsRepository());

      bloc.add(const ChatProjectOptionsRequested());
      final state =
          await bloc.stream.firstWhere((state) => state is ChatsLoaded);

      expect(state.projectOptions, {7: 'Website'});
      await bloc.close();
    });

    test('exposes repository failures', () async {
      final bloc = ChatsBloc(
        repository: _FakeChatsRepository(fail: true),
      );

      bloc.add(const ChatsRequested());
      final state = await bloc.stream
          .firstWhere((state) => state is ChatsFailed) as ChatsFailed;

      expect(state.message, 'Could not load chats');
      await bloc.close();
    });
  });
}

class _FakeChatsRepository implements ChatsRepository {
  _FakeChatsRepository({this.fail = false});

  final bool fail;
  int? projectId;

  @override
  Future<Either<ServerFailure, List<ChatsModel>>> getChats({
    int? projectId,
  }) async {
    this.projectId = projectId;
    if (fail) {
      return left(ServerFailure('Could not load chats'));
    }
    return right([]);
  }

  @override
  Future<Either<ServerFailure, Map<int, String>>>
      getProjectChatOptions() async {
    return right({7: 'Website'});
  }
}
