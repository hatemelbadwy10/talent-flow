import '../model/account_statement_response_model.dart';

sealed class AccountStatementState {
  const AccountStatementState();
}

final class AccountStatementInitial extends AccountStatementState {
  const AccountStatementInitial();
}

final class AccountStatementLoading extends AccountStatementState {
  const AccountStatementLoading();
}

final class AccountStatementLoaded extends AccountStatementState {
  const AccountStatementLoaded(this.statements);
  final List<AccountStatementItemModel> statements;
}

final class AccountStatementFailed extends AccountStatementState {
  const AccountStatementFailed(this.message);
  final String message;
}
