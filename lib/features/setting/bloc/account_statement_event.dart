sealed class AccountStatementEvent {
  const AccountStatementEvent();
}

final class AccountStatementsRequested extends AccountStatementEvent {
  const AccountStatementsRequested({
    this.search,
    this.page,
    this.perPage,
  });

  final String? search;
  final int? page;
  final int? perPage;
}
