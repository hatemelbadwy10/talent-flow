import 'package:equatable/equatable.dart';

abstract class NavBarEvent extends Equatable {
  const NavBarEvent();

  @override
  List<Object?> get props => [];
}

class NavBarTabChanged extends NavBarEvent {
  const NavBarTabChanged(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}
