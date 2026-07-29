import '../model/selection_option_model.dart';

sealed class SelectionOptionState {
  const SelectionOptionState();
}

final class SelectionOptionInitial extends SelectionOptionState {
  const SelectionOptionInitial();
}

final class SelectionOptionLoading extends SelectionOptionState {
  const SelectionOptionLoading();
}

final class SelectionOptionLoaded extends SelectionOptionState {
  const SelectionOptionLoaded(this.options);
  final SelectionModel options;
}

final class SelectionOptionFailed extends SelectionOptionState {
  const SelectionOptionFailed(this.message);
  final String message;
}
