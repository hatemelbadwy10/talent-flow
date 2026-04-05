import 'package:equatable/equatable.dart';

class NavBarState extends Equatable {
  const NavBarState({
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  List<Object?> get props => [currentIndex];
}
