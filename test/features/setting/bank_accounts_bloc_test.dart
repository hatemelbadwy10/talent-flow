import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/bank_accounts_bloc.dart';
import 'package:talent_flow/features/setting/bloc/bank_accounts_event.dart';
import 'package:talent_flow/features/setting/model/bank_accounts_request_model.dart';
import 'package:talent_flow/features/setting/model/bank_accounts_response_model.dart';
import 'package:talent_flow/features/setting/repo/bank_accounts_repository.dart';

void main() {
  test('BankAccountsBloc loads accounts and bank options', () async {
    final repository = _FakeBankAccountsRepository();
    final bloc = BankAccountsBloc(repository: repository)
      ..add(const FetchBankAccounts());

    final state = await bloc.stream.firstWhere(
      (state) =>
          !state.isLoading &&
          state.accounts.isNotEmpty &&
          state.bankOptions.isNotEmpty,
    );
    expect(state.accounts, same(repository.accounts));
    expect(state.bankOptions, same(repository.options));
    await bloc.close();
  });

  test('adding a bank account refreshes the typed account list', () async {
    final repository = _FakeBankAccountsRepository();
    final bloc = BankAccountsBloc(repository: repository);
    const request = BankAccountUpsertRequestModel(
      name: 'Main account',
      number: '1234',
      bankId: 2,
    );

    bloc.add(const AddBankAccount(request: request));

    final state = await bloc.stream.firstWhere(
      (state) => state.successMessage == 'Account saved',
    );
    expect(repository.addRequest, same(request));
    expect(state.accounts, same(repository.accounts));
    await bloc.close();
  });
}

class _FakeBankAccountsRepository implements BankAccountsRepository {
  final accounts = <BankAccountModel>[
    BankAccountModel.fromJson(const {'id': 1, 'name': 'Main'}),
  ];
  final options = <BankOptionModel>[
    BankOptionModel.fromJson(const {'id': 2, 'name': 'Bank'}),
  ];
  BankAccountUpsertRequestModel? addRequest;

  @override
  Future<Either<ServerFailure, BankAccountsResponseModel>>
      getBankAccounts() async {
    return right(BankAccountsResponseModel(items: accounts));
  }

  @override
  Future<Either<ServerFailure, BankOptionsResponseModel>>
      getBanksOptions() async {
    return right(BankOptionsResponseModel(options: options));
  }

  @override
  Future<Either<ServerFailure, BankAccountMutationResponseModel>>
      addBankAccount({
    required BankAccountUpsertRequestModel request,
  }) async {
    addRequest = request;
    return right(const BankAccountMutationResponseModel(
      message: 'Account saved',
    ));
  }

  @override
  Future<Either<ServerFailure, BankAccountMutationResponseModel>>
      updateBankAccount({
    required BankAccountUpsertRequestModel request,
  }) async {
    return right(const BankAccountMutationResponseModel());
  }

  @override
  Future<Either<ServerFailure, BankAccountMutationResponseModel>>
      deleteBankAccount({
    required int id,
  }) async {
    return right(const BankAccountMutationResponseModel());
  }
}
