import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/home/model/home_model.dart';
import 'package:talent_flow/features/home/page/all_categories.dart';
import 'package:talent_flow/features/home/repo/categories_repository.dart';

void main() {
  testWidgets('shows loading while categories are pending', (tester) async {
    final repository = _FakeCategoriesRepository.pending();

    await tester.pumpWidget(_app(repository));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the empty state when no categories are returned',
      (tester) async {
    final repository = _FakeCategoriesRepository.success(const []);

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('no_categories_found'), findsOneWidget);
  });

  testWidgets('shows the failure state when loading fails', (tester) async {
    final repository = _FakeCategoriesRepository.failure('Offline');

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('error_loading_categories'), findsOneWidget);
  });

  testWidgets('shows category content after a successful load', (tester) async {
    final repository = _FakeCategoriesRepository.success([
      Category(
        id: 1,
        name: 'Design',
        description: 'UI and UX',
        icon: '',
      ),
    ]);

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('Design'), findsOneWidget);
    expect(find.text('UI and UX'), findsOneWidget);
    expect(find.byType(ServiceCategoryTile), findsOneWidget);
  });
}

Widget _app(CategoriesRepository repository) {
  return MaterialApp(
    home: ServiceCategoryView(
      repository: repository,
      isFreelancer: true,
    ),
  );
}

class _FakeCategoriesRepository implements CategoriesRepository {
  _FakeCategoriesRepository._(this._result);

  factory _FakeCategoriesRepository.pending() {
    return _FakeCategoriesRepository._(
        Completer<Either<ServerFailure, List<Category>>>().future);
  }

  factory _FakeCategoriesRepository.success(List<Category> categories) {
    return _FakeCategoriesRepository._(
      Future.value(right(categories)),
    );
  }

  factory _FakeCategoriesRepository.failure(String message) {
    return _FakeCategoriesRepository._(
      Future.value(left(ServerFailure(message))),
    );
  }

  final Future<Either<ServerFailure, List<Category>>> _result;

  @override
  Future<Either<ServerFailure, List<Category>>> getCategoryList() => _result;
}
