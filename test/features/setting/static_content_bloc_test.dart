import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/about_bloc.dart';
import 'package:talent_flow/features/setting/bloc/static_content_state.dart';
import 'package:talent_flow/features/setting/bloc/terms_bloc.dart';
import 'package:talent_flow/features/setting/repo/about_repository.dart';
import 'package:talent_flow/features/setting/repo/terms_repository.dart';

void main() {
  test('AboutBloc emits typed HTML content', () async {
    final bloc = AboutBloc(repository: _FakeAboutRepository())
      ..add(const AboutRequested());
    final state = await bloc.stream.firstWhere(
      (state) => state is StaticContentLoaded,
    ) as StaticContentLoaded;
    expect(state.html, '<p>About</p>');
    await bloc.close();
  });

  test('TermsBloc exposes repository failures', () async {
    final bloc = TermsBloc(repository: _FakeTermsRepository())
      ..add(const TermsRequested());
    final state = await bloc.stream.firstWhere(
      (state) => state is StaticContentFailed,
    ) as StaticContentFailed;
    expect(state.message, 'Terms failed');
    await bloc.close();
  });
}

class _FakeAboutRepository implements AboutRepository {
  @override
  Future<Either<ServerFailure, String>> getAboutContent() async {
    return right('<p>About</p>');
  }
}

class _FakeTermsRepository implements TermsRepository {
  @override
  Future<Either<ServerFailure, String>> getTermsAndCondition() async {
    return left(ServerFailure('Terms failed'));
  }
}
