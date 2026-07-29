import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/auth/pages/change_password/bloc/change_password_bloc.dart';
import 'package:talent_flow/features/auth/pages/change_password/bloc/change_password_event.dart';
import 'package:talent_flow/features/auth/pages/change_password/bloc/change_password_state.dart';
import 'package:talent_flow/features/auth/pages/change_password/repo/change_password_repository.dart';

void main() {
  test('ChangePasswordBloc forwards typed password fields', () async {
    final repository = _FakeChangePasswordRepository();
    final bloc = ChangePasswordBloc(repository: repository)
      ..add(const ChangePasswordSubmitted(
        identifier: 'user@example.com',
        password: 'secret1',
        passwordConfirmation: 'secret1',
      ));

    final state = await bloc.stream.firstWhere(
      (state) => state is ChangePasswordSucceeded,
    ) as ChangePasswordSucceeded;
    expect(repository.identifier, 'user@example.com');
    expect(repository.password, 'secret1');
    expect(state.message, 'Changed');
    await bloc.close();
  });

  test('ChangePasswordBloc exposes repository failures', () async {
    final bloc = ChangePasswordBloc(
      repository: _FakeChangePasswordRepository(fail: true),
    )..add(const ChangePasswordSubmitted(
        identifier: 'user@example.com',
        password: 'secret1',
        passwordConfirmation: 'secret1',
      ));

    final state = await bloc.stream.firstWhere(
      (state) => state is ChangePasswordFailed,
    ) as ChangePasswordFailed;
    expect(state.message, 'Change failed');
    await bloc.close();
  });
}

class _FakeChangePasswordRepository implements ChangePasswordRepository {
  _FakeChangePasswordRepository({this.fail = false});

  final bool fail;
  String? identifier;
  String? password;

  @override
  Future<Either<ServerFailure, String>> changePassword({
    required String identifier,
    required String password,
    required String passwordConfirmation,
  }) async {
    this.identifier = identifier;
    this.password = password;
    return fail ? left(ServerFailure('Change failed')) : right('Changed');
  }
}
