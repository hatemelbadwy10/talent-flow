import '../model/account_statement_response_model.dart';

sealed class AccountStatementDetailsState {
  const AccountStatementDetailsState();
}

final class AccountStatementDetailsInitial
    extends AccountStatementDetailsState {
  const AccountStatementDetailsInitial();
}

final class AccountStatementDetailsLoading
    extends AccountStatementDetailsState {
  const AccountStatementDetailsLoading();
}

final class AccountStatementDetailsLoaded extends AccountStatementDetailsState {
  const AccountStatementDetailsLoaded(this.statement);
  final AccountStatementItemModel statement;
}

final class AccountStatementDetailsFailed extends AccountStatementDetailsState {
  const AccountStatementDetailsFailed(this.message);
  final String message;
}
