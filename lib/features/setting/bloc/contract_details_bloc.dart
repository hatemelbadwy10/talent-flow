import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../model/contract_model.dart';
import '../repo/contracts_repo.dart';

class ContractDetailsBloc extends Bloc<AppEvent, AppState> {
  ContractDetailsBloc(this._contractsRepo) : super(Start()) {
    on<Add>(_onGetContractDetails);
  }

  final ContractsRepo _contractsRepo;

  Future<void> _onGetContractDetails(Add event, Emitter<AppState> emit) async {
    emit(Loading());
    final id = event.arguments;
    if (id is! int) {
      emit(Error());
      return;
    }

    try {
      final result = await _contractsRepo.getContractDetails(id);
      result.fold(
        (failure) {
          log('Contract details error: $failure');
          emit(Error());
        },
        (response) {
          final body = response.data;
          final payload =
              body is Map<String, dynamic> && body['payload'] != null
                  ? body['payload']
                  : body;

          if (payload is! Map) {
            emit(Error());
            return;
          }

          final data = Map<String, dynamic>.from(payload);
          emit(Done(model: ContractModel.fromJson(data)));
        },
      );
    } catch (e, s) {
      log('Exception in ContractDetailsBloc', error: e, stackTrace: s);
      emit(Error());
    }
  }
}
