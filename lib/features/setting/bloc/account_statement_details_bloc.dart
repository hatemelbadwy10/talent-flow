import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/account_statement_request_model.dart';
import '../repo/account_statements_repository.dart';
import 'account_statement_details_event.dart';
import 'account_statement_details_state.dart';

class AccountStatementDetailsBloc
    extends Bloc<AccountStatementDetailsEvent, AccountStatementDetailsState> {
  AccountStatementDetailsBloc({
    required AccountStatementsRepository repository,
  })  : _repository = repository,
        super(const AccountStatementDetailsInitial()) {
    on<AccountStatementDetailsRequested>(_onRequested);
  }

  final AccountStatementsRepository _repository;

  Future<void> _onRequested(
    AccountStatementDetailsRequested event,
    Emitter<AccountStatementDetailsState> emit,
  ) async {
    emit(const AccountStatementDetailsLoading());
    final result = await _repository.getAccountStatementShow(
      request: AccountStatementShowRequestModel(id: event.statementId),
    );
    result.fold(
      (failure) => emit(AccountStatementDetailsFailed(failure.error)),
      (response) {
        final statement = response.item;
        if (statement == null) {
          emit(const AccountStatementDetailsFailed(
            'Account statement payload is invalid',
          ));
          return;
        }
        emit(AccountStatementDetailsLoaded(statement));
      },
    );
  }
}
