class AccountStatementIndexRequestModel {
  const AccountStatementIndexRequestModel({
    this.search,
    this.page,
    this.perPage,
  });

  final String? search;
  final int? page;
  final int? perPage;

  Map<String, dynamic> toQueryParameters() {
    return {
      if (search != null && search!.trim().isNotEmpty) 'search': search,
      if (page != null) 'page': page,
      if (perPage != null) 'per_page': perPage,
    };
  }
}

class AccountStatementShowRequestModel {
  const AccountStatementShowRequestModel({required this.id});

  final int id;
}
