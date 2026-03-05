import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../model/contract_model.dart';
import '../repo/contracts_repo.dart';

class ContractsBloc extends Bloc<AppEvent, AppState> {
  ContractsBloc(this._contractsRepo) : super(Start()) {
    on<Add>(_onGetContracts);
  }

  final ContractsRepo _contractsRepo;

  Future<void> _onGetContracts(Add event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final result = await _contractsRepo.getContracts();
      result.fold(
        (failure) {
          log('Contracts error: $failure');
          emit(Error());
        },
        (response) {
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }

          final payload = response.data['payload'];
          if (payload is! List) {
            emit(Error());
            return;
          }

          final contracts = payload
              .whereType<Map<String, dynamic>>()
              .map(ContractModel.fromJson)
              .toList();

          emit(Done(list: contracts));
        },
      );
    } catch (e, s) {
      log('Exception in ContractsBloc', error: e, stackTrace: s);
      emit(Error());
    }
  }
}
