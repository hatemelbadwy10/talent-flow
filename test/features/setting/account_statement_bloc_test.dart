import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/account_statement_bloc.dart';
import 'package:talent_flow/features/setting/bloc/account_statement_details_bloc.dart';
import 'package:talent_flow/features/setting/bloc/account_statement_details_event.dart';
import 'package:talent_flow/features/setting/bloc/account_statement_details_state.dart';
import 'package:talent_flow/features/setting/bloc/account_statement_event.dart';
import 'package:talent_flow/features/setting/bloc/account_statement_state.dart';
import 'package:talent_flow/features/setting/model/account_statement_request_model.dart';
import 'package:talent_flow/features/setting/model/account_statement_response_model.dart';
import 'package:talent_flow/features/setting/repo/account_statements_repository.dart';

void main() {
  test('AccountStatementBloc forwards typed filters', () async {
    final repository = _FakeAccountStatementsRepository();
    final bloc = AccountStatementBloc(repository: repository)
      ..add(const AccountStatementsRequested(
        search: 'project',
        page: 2,
        perPage: 20,
      ));

    final state = await bloc.stream.firstWhere(
      (state) => state is AccountStatementLoaded,
    ) as AccountStatementLoaded;
    expect(repository.indexRequest?.search, 'project');
    expect(repository.indexRequest?.page, 2);
    expect(repository.indexRequest?.perPage, 20);
    expect(state.statements, same(repository.items));
    await bloc.close();
  });

  test('AccountStatementDetailsBloc forwards the statement id', () async {
    final repository = _FakeAccountStatementsRepository();
    final bloc = AccountStatementDetailsBloc(repository: repository)
      ..add(const AccountStatementDetailsRequested(7));

    final state = await bloc.stream.firstWhere(
      (state) => state is AccountStatementDetailsLoaded,
    ) as AccountStatementDetailsLoaded;
    expect(repository.showRequest?.id, 7);
    expect(state.statement, same(repository.item));
    await bloc.close();
  });

  test('AccountStatementBloc exposes repository failures', () async {
    final bloc = AccountStatementBloc(
      repository: _FakeAccountStatementsRepository(fail: true),
    )..add(const AccountStatementsRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is AccountStatementFailed,
    ) as AccountStatementFailed;
    expect(state.message, 'Statements failed');
    await bloc.close();
  });
}

class _FakeAccountStatementsRepository implements AccountStatementsRepository {
  _FakeAccountStatementsRepository({this.fail = false});

  final bool fail;
  final item = AccountStatementItemModel.fromJson(const {'id': 7});
  late final items = <AccountStatementItemModel>[item];
  AccountStatementIndexRequestModel? indexRequest;
  AccountStatementShowRequestModel? showRequest;

  @override
  Future<Either<ServerFailure, AccountStatementIndexResponseModel>>
      getAccountStatementIndex({
    AccountStatementIndexRequestModel request =
        const AccountStatementIndexRequestModel(),
  }) async {
    indexRequest = request;
    return fail
        ? left(ServerFailure('Statements failed'))
        : right(AccountStatementIndexResponseModel(items: items));
  }

  @override
  Future<Either<ServerFailure, AccountStatementShowResponseModel>>
      getAccountStatementShow({
    required AccountStatementShowRequestModel request,
  }) async {
    showRequest = request;
    return fail
        ? left(ServerFailure('Statement failed'))
        : right(AccountStatementShowResponseModel(item: item));
  }
}
