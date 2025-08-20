import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';


class NavBarBloc extends Bloc<AppEvent, AppState> {
  NavBarBloc() : super(Done(data: 2)) {
    on<Click>((event, emit) {
      emit(Done(data: event.arguments));
    });
  }
}