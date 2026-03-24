class BankAccountUpsertRequestModel {
  const BankAccountUpsertRequestModel({
    this.id,
    required this.name,
    required this.number,
    required this.bankId,
  });

  final int? id;
  final String name;
  final String number;
  final int bankId;

  Map<String, dynamic> toQueryParameters() {
    return {
      'name': name,
      'number': number,
      'bank_id': bankId,
    };
  }
}
