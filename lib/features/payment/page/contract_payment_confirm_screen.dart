import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/payment/model/contract_payment_args.dart';
import 'package:talent_flow/features/payment/repo/pay_ment_repo.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

class ContractPaymentConfirmScreen extends StatefulWidget {
  const ContractPaymentConfirmScreen({
    super.key,
    required this.arguments,
  });

  final ContractPaymentConfirmArgs arguments;

  @override
  State<ContractPaymentConfirmScreen> createState() =>
      _ContractPaymentConfirmScreenState();
}

class _ContractPaymentConfirmScreenState
    extends State<ContractPaymentConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  bool _isSubmitting = false;
  bool _isResending = false;

  PaymentRepo get _paymentRepo => sl<PaymentRepo>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final result = await _paymentRepo.confirmContractPayment(
      customerNumber: widget.arguments.customerNumber,
      paymentCode: widget.arguments.paymentCode,
      paymentAmount: widget.arguments.paymentAmount,
      paymentOtp: _otpController.text.trim(),
      contractId: widget.arguments.contractId,
      startDate: widget.arguments.startDate,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) {
        AppCore.showSnackBar(
          notification: AppNotification(
            message: failure.error,
            backgroundColor: Styles.LOGOUT_COLOR,
            isFloating: true,
          ),
        );
      },
      (response) {
        final message = _paymentRepo.messageFromResponse(
          response,
          fallback: 'contract_payment.confirm_success'.tr(),
        );
        CustomNavigator.pop(result: message);
      },
    );
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    final result = await _paymentRepo.requestContractPayment(
      customerNumber: widget.arguments.customerNumber,
      paymentCode: widget.arguments.paymentCode,
      paymentAmount: widget.arguments.paymentAmount,
    );
    if (!mounted) return;
    setState(() => _isResending = false);

    result.fold(
      (failure) {
        AppCore.showSnackBar(
          notification: AppNotification(
            message: failure.error,
            backgroundColor: Styles.LOGOUT_COLOR,
            isFloating: true,
          ),
        );
      },
      (response) {
        final message = _paymentRepo.messageFromResponse(
          response,
          fallback: 'contract_payment.request_success'.tr(),
        );
        AppCore.showSnackBar(
          notification: AppNotification(
            message: message,
            backgroundColor: Styles.PRIMARY_COLOR,
            isFloating: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'contract_payment.confirm_title'.tr(),
        centerTitle: true,
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'contract_payment.confirm_heading'.tr(),
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'contract_payment.confirm_subtitle'.tr(),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _otpController,
                withLabel: true,
                label: 'contract_payment.otp'.tr(),
                hint: 'contract_payment.otp_hint'.tr(),
                inputType: TextInputType.number,
                formattedType: [FilteringTextInputFormatter.digitsOnly],
                sufWidget: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Styles.HINT_COLOR,
                ),
                validate: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'contract_payment.otp_required'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              CustomButton(
                text: 'contract_payment.confirm_button'.tr(),
                radius: 18,
                height: 56,
                isLoading: _isSubmitting,
                onTap: _submit,
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _isResending ? null : _resendCode,
                child: Center(
                  child: _isResending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Styles.PRIMARY_COLOR,
                          ),
                        )
                      : Text(
                          'contract_payment.resend_code'.tr(),
                          style: const TextStyle(
                            color: Styles.PRIMARY_COLOR,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
