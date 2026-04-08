import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talent_flow/app/core/app_currency.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/payment/model/contract_payment_args.dart';
import 'package:talent_flow/features/payment/repo/pay_ment_repo.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/helpers/date_time_picker.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class ContractPaymentRequestScreen extends StatefulWidget {
  const ContractPaymentRequestScreen({
    super.key,
    required this.arguments,
  });

  final ContractPaymentRequestArgs arguments;

  @override
  State<ContractPaymentRequestScreen> createState() =>
      _ContractPaymentRequestScreenState();
}

class _ContractPaymentRequestScreenState
    extends State<ContractPaymentRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNumberController = TextEditingController();
  final _paymentCodeController = TextEditingController();
  late final TextEditingController _amountController;
  late final TextEditingController _startDateController;

  bool _isSubmitting = false;

  PaymentRepo get _paymentRepo => sl<PaymentRepo>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: _normalizeAmount(widget.arguments.initialAmount),
    );
    _startDateController = TextEditingController(
      text: _normalizeStartDate(widget.arguments.initialStartDate),
    );
  }

  @override
  void dispose() {
    _customerNumberController.dispose();
    _paymentCodeController.dispose();
    _amountController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final parsedDate = _tryParseDate(_startDateController.text);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DateTimePicker(
        label: 'contract_payment.start_date'.tr(),
        initialString: parsedDate?.toIso8601String(),
        isNotEmptyValue: parsedDate != null,
        startDateTime: parsedDate ?? DateTime.now(),
        minDateTime: DateTime(2020),
        valueChanged: (value) {
          final month = value.month.toString().padLeft(2, '0');
          final day = value.day.toString().padLeft(2, '0');
          _startDateController.text = '${value.year}/$month/$day';
        },
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final result = await _paymentRepo.requestContractPayment(
      customerNumber: _customerNumberController.text.trim(),
      paymentCode: _paymentCodeController.text.trim(),
      paymentAmount: _amountController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    await result.fold(
      (failure) async {
        AppCore.showSnackBar(
          notification: AppNotification(
            message: failure.error,
            backgroundColor: Styles.LOGOUT_COLOR,
            isFloating: true,
          ),
        );
      },
      (_) async {
        final confirmationResult = await CustomNavigator.push(
          Routes.contractPaymentConfirm,
          arguments: ContractPaymentConfirmArgs(
            contractId: widget.arguments.contractId,
            customerNumber: _customerNumberController.text.trim(),
            paymentCode: _paymentCodeController.text.trim(),
            paymentAmount: _amountController.text.trim(),
            startDate: _startDateController.text.trim(),
          ),
        );

        if (confirmationResult is String &&
            confirmationResult.trim().isNotEmpty) {
          CustomNavigator.pop(result: confirmationResult);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'contract_payment.request_title'.tr(),
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
              _field(
                controller: _customerNumberController,
                label: 'contract_payment.customer_number'.tr(),
                hint: 'contract_payment.customer_number_hint'.tr(),
                inputType: TextInputType.phone,
                formattedType: [FilteringTextInputFormatter.digitsOnly],
                sufWidget: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Styles.HINT_COLOR,
                ),
                validate: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'contract_payment.customer_number_required'.tr();
                  }
                  return null;
                },
              ),
              _field(
                controller: _paymentCodeController,
                label: 'contract_payment.payment_code'.tr(),
                hint: 'contract_payment.payment_code_hint'.tr(),
                inputType: TextInputType.number,
                formattedType: [FilteringTextInputFormatter.digitsOnly],
                validate: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'contract_payment.payment_code_required'.tr();
                  }
                  return null;
                },
              ),
              _field(
                controller: _amountController,
                label: 'contract_payment.amount'.tr(),
                hint: 'contract_payment.amount_hint'.tr(),
                inputType: const TextInputType.numberWithOptions(decimal: true),
                formattedType: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validate: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'contract_payment.amount_required'.tr();
                  }
                  return null;
                },
                sufWidget: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Text(
                    AppCurrency.code,
                    style: const TextStyle(
                      color: Styles.HINT_COLOR,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _field(
                controller: _startDateController,
                label: 'contract_payment.start_date'.tr(),
                hint: 'contract_payment.start_date_hint'.tr(),
                readOnly: true,
                onTap: _pickStartDate,
                sufWidget: const Icon(
                  Icons.calendar_month_outlined,
                  color: Styles.HINT_COLOR,
                ),
                validate: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'contract_payment.start_date_required'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              CustomButton(
                text: 'contract_payment.request_button'.tr(),
                radius: 18,
                height: 56,
                isLoading: _isSubmitting,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    FormFieldValidator<String>? validate,
    TextInputType? inputType,
    List<TextInputFormatter>? formattedType,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? sufWidget,
  }) {
    return CustomTextField(
      controller: controller,
      withLabel: true,
      label: label,
      hint: hint,
      validate: validate,
      inputType: inputType,
      formattedType: formattedType,
      readOnly: readOnly,
      onTap: onTap,
      sufWidget: sufWidget,
    );
  }

  String _normalizeAmount(String? rawAmount) {
    final source = (rawAmount?.trim() ?? '').replaceAll(',', '');
    if (source.isEmpty) return '';
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(source);
    return match?.group(0) ?? source;
  }

  String _normalizeStartDate(String? rawDate) {
    final parsedDate = _tryParseDate(rawDate);
    if (parsedDate == null) return '';
    final month = parsedDate.month.toString().padLeft(2, '0');
    final day = parsedDate.day.toString().padLeft(2, '0');
    return '${parsedDate.year}/$month/$day';
  }

  DateTime? _tryParseDate(String? rawDate) {
    final source = rawDate?.trim();
    if (source == null || source.isEmpty) return null;

    final normalized = source.replaceAll('/', '-');
    return DateTime.tryParse(normalized);
  }
}
