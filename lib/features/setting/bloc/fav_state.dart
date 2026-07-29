import '../model/favourite_model.dart';

sealed class FavouriteState {
  const FavouriteState();
}

final class FavouriteInitial extends FavouriteState {
  const FavouriteInitial();
}

final class FavouriteLoading extends FavouriteState {
  const FavouriteLoading();
}

final class FavouriteLoaded extends FavouriteState {
  const FavouriteLoaded(this.favourites);
  final FavouriteResponseModel favourites;
}

final class FavouriteFailed extends FavouriteState {
  const FavouriteFailed(this.message);
  final String message;
}
