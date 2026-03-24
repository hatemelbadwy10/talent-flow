import 'package:equatable/equatable.dart';

import '../model/bank_accounts_request_model.dart';

abstract class BankAccountsEvent extends Equatable {
  const BankAccountsEvent();

  @override
  List<Object?> get props => [];
}

class FetchBankAccounts extends BankAccountsEvent {
  const FetchBankAccounts({this.showLoading = true});

  final bool showLoading;

  @override
  List<Object?> get props => [showLoading];
}

class AddBankAccount extends BankAccountsEvent {
  const AddBankAccount({required this.request});

  final BankAccountUpsertRequestModel request;

  @override
  List<Object?> get props => [request];
}

class UpdateBankAccount extends BankAccountsEvent {
  const UpdateBankAccount({required this.request});

  final BankAccountUpsertRequestModel request;

  @override
  List<Object?> get props => [request];
}

class DeleteBankAccount extends BankAccountsEvent {
  const DeleteBankAccount({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}
