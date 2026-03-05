import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../model/account_statement_request_model.dart';
import '../repo/account_statement_repo.dart';

class AccountStatementBloc extends Bloc<AppEvent, AppState> {
  AccountStatementBloc(this._repo) : super(Start()) {
    on<Add>(_onGetAccountStatements);
  }

  final AccountStatementRepo _repo;

  Future<void> _onGetAccountStatements(
    Add event,
    Emitter<AppState> emit,
  ) async {
    emit(Loading());
    try {
      final args = event.arguments;
      final map =
          args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};
      final request = AccountStatementIndexRequestModel(
        search: map['search']?.toString(),
        page: _toInt(map['page']),
        perPage: _toInt(map['per_page']),
      );

      final result = await _repo.getAccountStatementIndex(request: request);
      result.fold(
        (failure) {
          log('Account statement index error: $failure');
          emit(Error());
        },
        (response) {
          emit(Done(list: response.items));
        },
      );
    } catch (e, s) {
      log('Exception in AccountStatementBloc', error: e, stackTrace: s);
      emit(Error());
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }
}
