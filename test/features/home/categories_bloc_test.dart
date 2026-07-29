import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/home/bloc/categories_bloc.dart';
import 'package:talent_flow/features/home/bloc/categories_event.dart';
import 'package:talent_flow/features/home/bloc/categories_state.dart';
import 'package:talent_flow/features/home/model/home_model.dart';
import 'package:talent_flow/features/home/repo/categories_repository.dart';

void main() {
  group('CategoriesBloc', () {
    test('emits a typed category list', () async {
      final categories = [
        Category(
          id: 1,
          name: 'Development',
          description: 'Software development',
          icon: 'icon.png',
        ),
      ];
      final bloc = CategoriesBloc(
        repository: _FakeCategoriesRepository(right(categories)),
      );

      bloc.add(const CategoriesRequested());
      final state = await bloc.stream.firstWhere(
        (state) => state is CategoriesLoaded,
      ) as CategoriesLoaded;

      expect(state.categories, same(categories));
      await bloc.close();
    });

    test('supports an empty category list', () async {
      final bloc = CategoriesBloc(
        repository: _FakeCategoriesRepository(right(const [])),
      );

      bloc.add(const CategoriesRequested());
      final state = await bloc.stream.firstWhere(
        (state) => state is CategoriesLoaded,
      ) as CategoriesLoaded;

      expect(state.categories, isEmpty);
      await bloc.close();
    });

    test('exposes repository failures', () async {
      final bloc = CategoriesBloc(
        repository: _FakeCategoriesRepository(
          left(ServerFailure('Unable to load categories')),
        ),
      );

      bloc.add(const CategoriesRequested());
      final state = await bloc.stream.firstWhere(
        (state) => state is CategoriesFailed,
      ) as CategoriesFailed;

      expect(state.message, 'Unable to load categories');
      await bloc.close();
    });
  });
}

class _FakeCategoriesRepository implements CategoriesRepository {
  _FakeCategoriesRepository(this.result);

  final Either<ServerFailure, List<Category>> result;

  @override
  Future<Either<ServerFailure, List<Category>>> getCategoryList() async {
    return result;
  }
}
