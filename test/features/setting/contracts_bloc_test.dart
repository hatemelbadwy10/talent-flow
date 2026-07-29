import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/contract_details_bloc.dart';
import 'package:talent_flow/features/setting/bloc/contract_details_event.dart';
import 'package:talent_flow/features/setting/bloc/contract_details_state.dart';
import 'package:talent_flow/features/setting/bloc/contracts_bloc.dart';
import 'package:talent_flow/features/setting/bloc/contracts_event.dart';
import 'package:talent_flow/features/setting/bloc/contracts_state.dart';
import 'package:talent_flow/features/setting/model/contract_model.dart';
import 'package:talent_flow/features/setting/repo/contracts_repository.dart';

void main() {
  test('ContractsBloc emits a typed contract list', () async {
    final repository = _FakeContractsRepository();
    final bloc = ContractsBloc(repository: repository)
      ..add(const ContractsRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is ContractsLoaded,
    ) as ContractsLoaded;
    expect(state.contracts, same(repository.contracts));
    await bloc.close();
  });

  test('ContractDetailsBloc forwards the contract id', () async {
    final repository = _FakeContractsRepository();
    final bloc = ContractDetailsBloc(repository: repository)
      ..add(const ContractDetailsRequested(14));

    final state = await bloc.stream.firstWhere(
      (state) => state is ContractDetailsLoaded,
    ) as ContractDetailsLoaded;
    expect(repository.contractId, 14);
    expect(state.contract, same(repository.contract));
    await bloc.close();
  });

  test('ContractsBloc exposes repository failures', () async {
    final bloc = ContractsBloc(
      repository: _FakeContractsRepository(fail: true),
    )..add(const ContractsRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is ContractsFailed,
    ) as ContractsFailed;
    expect(state.message, 'Contracts failed');
    await bloc.close();
  });
}

class _FakeContractsRepository implements ContractsRepository {
  _FakeContractsRepository({this.fail = false});

  final bool fail;
  final contract = ContractModel.fromJson(const {'id': 14});
  late final contracts = <ContractModel>[contract];
  int? contractId;

  @override
  Future<Either<ServerFailure, List<ContractModel>>> getContracts() async {
    return fail ? left(ServerFailure('Contracts failed')) : right(contracts);
  }

  @override
  Future<Either<ServerFailure, ContractModel>> getContractDetails(
      int id) async {
    contractId = id;
    return fail ? left(ServerFailure('Contract failed')) : right(contract);
  }
}
