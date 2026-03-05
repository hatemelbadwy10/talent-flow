import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../model/account_statement_request_model.dart';
import '../repo/account_statement_repo.dart';

class AccountStatementDetailsBloc extends Bloc<AppEvent, AppState> {
  AccountStatementDetailsBloc(this._repo) : super(Start()) {
    on<Add>(_onGetAccountStatementDetails);
  }

  final AccountStatementRepo _repo;

  Future<void> _onGetAccountStatementDetails(
    Add event,
    Emitter<AppState> emit,
  ) async {
    emit(Loading());
    final id = event.arguments;
    if (id is! int) {
      emit(Error());
      return;
    }

    try {
      final result = await _repo.getAccountStatementShow(
        request: AccountStatementShowRequestModel(id: id),
      );
      result.fold(
        (failure) {
          log('Account statement details error: $failure');
          emit(Error());
        },
        (response) {
          if (response.item == null) {
            emit(Error());
            return;
          }
          emit(Done(model: response.item));
        },
      );
    } catch (e, s) {
      log('Exception in AccountStatementDetailsBloc', error: e, stackTrace: s);
      emit(Error());
    }
  }
}
