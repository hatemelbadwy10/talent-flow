import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/fav_bloc.dart';
import 'package:talent_flow/features/setting/bloc/fav_event.dart';
import 'package:talent_flow/features/setting/bloc/fav_state.dart';
import 'package:talent_flow/features/setting/model/favourite_model.dart';
import 'package:talent_flow/features/setting/repo/favourites_repository.dart';

void main() {
  test('FavBloc emits typed favourites', () async {
    final repository = _FakeFavouritesRepository();
    final bloc = FavBloc(repository: repository)
      ..add(const FavouritesRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is FavouriteLoaded,
    ) as FavouriteLoaded;
    expect(state.favourites, same(repository.favourites));
    await bloc.close();
  });

  test('FavBloc toggles the selected favourite type then refreshes', () async {
    final repository = _FakeFavouritesRepository();
    final bloc = FavBloc(repository: repository)
      ..add(const FavouriteToggled(
        type: FavouriteType.freelancer,
        id: 8,
      ));

    await bloc.stream.firstWhere((state) => state is FavouriteLoaded);
    expect(repository.toggledFreelancerId, 8);
    expect(repository.fetchCount, 1);
    await bloc.close();
  });
}

class _FakeFavouritesRepository implements FavouritesRepository {
  final favourites = const FavouriteResponseModel(
    payload: FavouritePayloadModel(
      projects: [],
      freelancers: [],
      works: [],
    ),
  );
  int? toggledFreelancerId;
  int fetchCount = 0;

  @override
  Future<Either<ServerFailure, FavouriteResponseModel>> getFavourites() async {
    fetchCount++;
    return right(favourites);
  }

  @override
  Future<Either<ServerFailure, String>> toggleFreelancerFavourite(
    int id,
  ) async {
    toggledFreelancerId = id;
    return right('');
  }

  @override
  Future<Either<ServerFailure, String>> toggleProjectFavourite(int id) async {
    return right('');
  }

  @override
  Future<Either<ServerFailure, String>> toggleWorkFavourite(int id) async {
    return right('');
  }
}
