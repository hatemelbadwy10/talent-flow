enum FavouriteType { project, freelancer, work }

sealed class FavouriteEvent {
  const FavouriteEvent();
}

final class FavouritesRequested extends FavouriteEvent {
  const FavouritesRequested();
}

final class FavouriteToggled extends FavouriteEvent {
  const FavouriteToggled({
    required this.type,
    required this.id,
  });
  final FavouriteType type;
  final int id;
}
