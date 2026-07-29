import 'package:flutter_bloc/flutter_bloc.dart';

final class NavBarSelectionChanged {
  const NavBarSelectionChanged(this.index);

  final int index;
}

final class NavBarState {
  const NavBarState(this.selectedIndex);

  final int selectedIndex;
}

class NavBarBloc extends Bloc<NavBarSelectionChanged, NavBarState> {
  NavBarBloc() : super(const NavBarState(2)) {
    on<NavBarSelectionChanged>((event, emit) {
      emit(NavBarState(event.index));
    });
  }
}
