import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/identity_verification_bloc.dart';
import 'package:talent_flow/features/setting/bloc/identity_verification_event.dart';
import 'package:talent_flow/features/setting/bloc/identity_verification_state.dart';
import 'package:talent_flow/features/setting/model/identity_verification_details.dart';
import 'package:talent_flow/features/setting/model/identity_verification_request.dart';
import 'package:talent_flow/features/setting/repo/identity_verification_repository.dart';

void main() {
  test('IdentityVerificationBloc forwards the typed request', () async {
    final repository = _FakeIdentityVerificationRepository();
    final request = IdentityVerificationRequest(
      countryId: 1,
      firstNameAr: 'حاتم',
      lastNameAr: 'البدوي',
      firstNameEn: 'Hatem',
      lastNameEn: 'Elbadwy',
      dateOfBirth: '1990-01-01',
      idCardFrontFace: File('/tmp/front.jpg'),
      idCardBackFace: File('/tmp/back.jpg'),
      selfieWithIdCard: File('/tmp/selfie.jpg'),
    );
    final bloc = IdentityVerificationBloc(repository: repository)
      ..add(IdentityVerificationSubmitted(request));

    final state = await bloc.stream.firstWhere(
      (state) => state is IdentityVerificationSucceeded,
    ) as IdentityVerificationSucceeded;
    expect(repository.request, same(request));
    expect(state.message, 'Submitted');
    await bloc.close();
  });

  test('IdentityVerificationBloc exposes repository failures', () async {
    final repository = _FakeIdentityVerificationRepository(fail: true);
    final request = IdentityVerificationRequest(
      countryId: 1,
      firstNameAr: '',
      lastNameAr: '',
      firstNameEn: '',
      lastNameEn: '',
      dateOfBirth: '',
      idCardFrontFace: File('/tmp/front.jpg'),
      idCardBackFace: File('/tmp/back.jpg'),
      selfieWithIdCard: File('/tmp/selfie.jpg'),
    );
    final bloc = IdentityVerificationBloc(repository: repository)
      ..add(IdentityVerificationSubmitted(request));

    final state = await bloc.stream.firstWhere(
      (state) => state is IdentityVerificationFailed,
    ) as IdentityVerificationFailed;
    expect(state.message, 'Submission failed');
    await bloc.close();
  });
}

class _FakeIdentityVerificationRepository
    implements IdentityVerificationRepository {
  _FakeIdentityVerificationRepository({this.fail = false});

  final bool fail;
  IdentityVerificationRequest? request;

  @override
  Future<Either<ServerFailure, String>> submitIdentityVerification(
    IdentityVerificationRequest request,
  ) async {
    this.request = request;
    return fail ? left(ServerFailure('Submission failed')) : right('Submitted');
  }

  @override
  Future<Either<ServerFailure, IdentityVerificationDetails?>>
      getIdentityVerification() async {
    return right(null);
  }
}
