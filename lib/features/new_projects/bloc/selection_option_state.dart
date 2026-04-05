import 'package:equatable/equatable.dart';

import '../model/selection_option_model.dart';

sealed class SelectionOptionState extends Equatable {
  const SelectionOptionState();

  @override
  List<Object?> get props => [];
}

class SelectionOptionInitial extends SelectionOptionState {
  const SelectionOptionInitial();
}

class SelectionOptionLoading extends SelectionOptionState {
  const SelectionOptionLoading();
}

class SelectionOptionFailure extends SelectionOptionState {
  const SelectionOptionFailure({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class SelectionOptionLoaded extends SelectionOptionState {
  const SelectionOptionLoaded(this.selectionModel);

  final SelectionModel selectionModel;

  @override
  List<Object?> get props => [selectionModel];
}
