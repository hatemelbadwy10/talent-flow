import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/auth/pages/send_verification/model/send_verification_result.dart';
import 'package:talent_flow/features/auth/pages/send_verification/send_verification_bloc/send_verification_bloc.dart';
import 'package:talent_flow/features/auth/pages/send_verification/send_verification_bloc/send_verification_event.dart';
import 'package:talent_flow/features/auth/pages/send_verification/send_verification_bloc/send_verification_state.dart';
import 'package:talent_flow/features/auth/pages/send_verification/send_verification_repo/send_verification_repository.dart';

void main() {
  group('SendVerificationBloc', () {
    test('emits the identifier and server message on success', () async {
      final repository = _FakeSendVerificationRepository(
        result: right(
          const SendVerificationResult(message: 'Code sent'),
        ),
      );
      final bloc = SendVerificationBloc(repository: repository);

      bloc.add(const VerificationRequested(identifier: 'user@example.com'));
      final state = await bloc.stream.firstWhere(
        (state) => state is SendVerificationSucceeded,
      ) as SendVerificationSucceeded;

      expect(state.identifier, 'user@example.com');
      expect(state.message, 'Code sent');
      expect(repository.receivedIdentifier, 'user@example.com');
      await bloc.close();
    });

    test('emits the API failure message', () async {
      final repository = _FakeSendVerificationRepository(
        result: left(ServerFailure('Account not found')),
      );
      final bloc = SendVerificationBloc(repository: repository);

      bloc.add(const VerificationRequested(identifier: '+201000000000'));
      final state = await bloc.stream.firstWhere(
        (state) => state is SendVerificationFailed,
      ) as SendVerificationFailed;

      expect(state.message, 'Account not found');
      await bloc.close();
    });

    test('emits loading before success', () async {
      final repository = _FakeSendVerificationRepository(
        result: right(const SendVerificationResult(message: 'Code sent')),
      );
      final bloc = SendVerificationBloc(repository: repository);

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SendVerificationLoading>(),
          isA<SendVerificationSucceeded>(),
        ]),
      );
      bloc.add(const VerificationRequested(identifier: 'user@example.com'));
      await bloc.stream.firstWhere(
        (state) => state is SendVerificationSucceeded,
      );
      await bloc.close();
    });
  });
}

class _FakeSendVerificationRepository implements SendVerificationRepository {
  _FakeSendVerificationRepository({required this.result});

  final Either<ServerFailure, SendVerificationResult> result;
  String? receivedIdentifier;

  @override
  Future<Either<ServerFailure, SendVerificationResult>> sendVerification(
    String identifier,
  ) async {
    receivedIdentifier = identifier;
    return result;
  }
}
