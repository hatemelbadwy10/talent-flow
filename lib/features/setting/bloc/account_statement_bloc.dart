import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/account_statement_request_model.dart';
import '../repo/account_statements_repository.dart';
import 'account_statement_event.dart';
import 'account_statement_state.dart';

class AccountStatementBloc
    extends Bloc<AccountStatementEvent, AccountStatementState> {
  AccountStatementBloc({required AccountStatementsRepository repository})
      : _repository = repository,
        super(const AccountStatementInitial()) {
    on<AccountStatementsRequested>(_onRequested);
  }

  final AccountStatementsRepository _repository;

  Future<void> _onRequested(
    AccountStatementsRequested event,
    Emitter<AccountStatementState> emit,
  ) async {
    emit(const AccountStatementLoading());
    final result = await _repository.getAccountStatementIndex(
      request: AccountStatementIndexRequestModel(
        search: event.search,
        page: event.page,
        perPage: event.perPage,
      ),
    );
    result.fold(
      (failure) => emit(AccountStatementFailed(failure.error)),
      (response) => emit(AccountStatementLoaded(response.items)),
    );
  }
}
