import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/auth/pages/register/bloc/register_bloc.dart';
import 'package:talent_flow/features/auth/pages/register/bloc/register_event.dart';
import 'package:talent_flow/features/auth/pages/register/bloc/register_state.dart';
import 'package:talent_flow/features/auth/pages/register/model/register_request.dart';
import 'package:talent_flow/features/auth/pages/register/repo/register_repository.dart';

void main() {
  group('RegisterBloc', () {
    test('emits success containing the submitted email', () async {
      final repository = _FakeRegisterRepository(result: right(unit));
      final bloc = RegisterBloc(repository: repository);

      bloc.add(const RegisterSubmitted(_request));
      final state = await bloc.stream.firstWhere(
        (state) => state is RegisterSucceeded,
      ) as RegisterSucceeded;

      expect(state.email, _request.email);
      expect(repository.receivedRequest, same(_request));
      await bloc.close();
    });

    test('emits the API failure message', () async {
      final repository = _FakeRegisterRepository(
        result: left(ServerFailure('Email already exists')),
      );
      final bloc = RegisterBloc(repository: repository);

      bloc.add(const RegisterSubmitted(_request));
      final state = await bloc.stream.firstWhere(
        (state) => state is RegisterFailed,
      ) as RegisterFailed;

      expect(state.message, 'Email already exists');
      await bloc.close();
    });

    test('emits loading before the terminal state', () async {
      final repository = _FakeRegisterRepository(result: right(unit));
      final bloc = RegisterBloc(repository: repository);

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RegisterLoading>(),
          isA<RegisterSucceeded>(),
        ]),
      );
      bloc.add(const RegisterSubmitted(_request));
      await bloc.stream.firstWhere((state) => state is RegisterSucceeded);
      await bloc.close();
    });
  });
}

const _request = RegisterRequest(
  firstName: 'Talent',
  lastName: 'Flow',
  email: 'user@example.com',
  password: 'secret',
  userType: 'Freelancer',
);

class _FakeRegisterRepository implements RegisterRepository {
  _FakeRegisterRepository({required this.result});

  final Either<ServerFailure, Unit> result;
  RegisterRequest? receivedRequest;

  @override
  Future<Either<ServerFailure, Unit>> register(
    RegisterRequest request,
  ) async {
    receivedRequest = request;
    return result;
  }
}
