import '../model/home_model.dart';

sealed class CategoriesState {
  const CategoriesState();
}

final class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

final class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

final class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.categories);

  final List<Category> categories;
}

final class CategoriesFailed extends CategoriesState {
  const CategoriesFailed(this.message);

  final String message;
}
