import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/payment/bloc/payment_bloc.dart';
import 'package:talent_flow/features/payment/bloc/payment_event.dart';
import 'package:talent_flow/features/payment/bloc/payment_state.dart';
import 'package:talent_flow/features/payment/model/model.dart';
import 'package:talent_flow/features/payment/repo/payment_repository.dart';

void main() {
  test('PaymentBloc emits typed payment methods', () async {
    final repository = _FakePaymentRepository();
    final bloc = PaymentBloc(repository: repository)
      ..add(const PaymentMethodsRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is PaymentLoaded,
    ) as PaymentLoaded;
    expect(state.methods, same(repository.methods));
    await bloc.close();
  });

  test('PaymentBloc exposes repository failures', () async {
    final bloc = PaymentBloc(
      repository: _FakePaymentRepository(fail: true),
    )..add(const PaymentMethodsRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is PaymentFailed,
    ) as PaymentFailed;
    expect(state.message, 'Payment failed');
    await bloc.close();
  });
}

class _FakePaymentRepository implements PaymentRepository {
  _FakePaymentRepository({this.fail = false});

  final bool fail;
  final methods = <PaymentModel>[
    PaymentModel.fromJson(const {'id': 1})
  ];

  @override
  Future<Either<ServerFailure, List<PaymentModel>>> getPaymentMethods() async {
    return fail ? left(ServerFailure('Payment failed')) : right(methods);
  }

  @override
  Future<Either<ServerFailure, String>> requestContractPayment({
    required String customerNumber,
    required String paymentCode,
    required String paymentAmount,
  }) async {
    return right('Code sent');
  }

  @override
  Future<Either<ServerFailure, String>> confirmContractPayment({
    required String customerNumber,
    required String paymentCode,
    required String paymentAmount,
    required String paymentOtp,
    required int contractId,
    required String startDate,
  }) async {
    return right('Payment confirmed');
  }
}
