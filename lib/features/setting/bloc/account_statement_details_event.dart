sealed class AccountStatementDetailsEvent {
  const AccountStatementDetailsEvent();
}

final class AccountStatementDetailsRequested
    extends AccountStatementDetailsEvent {
  const AccountStatementDetailsRequested(this.statementId);
  final int statementId;
}
