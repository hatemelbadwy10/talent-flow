import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';

import '../app/core/styles.dart';
import '../app/core/text_styles.dart';

class CustomPinCodeField extends StatefulWidget {
  const CustomPinCodeField({
    super.key,
    this.onSave,
    this.validation,
    this.onChanged,
    this.controller,
  });

  final void Function(String?)? onSave;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validation;

  @override
  State<CustomPinCodeField> createState() => _CustomPinCodeFieldState();
}

class _CustomPinCodeFieldState extends State<CustomPinCodeField> {
  late final PinInputController _pinController;

  @override
  void initState() {
    super.initState();
    _pinController = PinInputController(
      textController: widget.controller,
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.05),
      child: MaterialPinFormField(
        length: 5,
        pinController: _pinController,
        validator: widget.validation,
        onSaved: widget.onSave,
        onChanged: widget.onChanged,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        enableAutofill: true,
        autofillHints: const [AutofillHints.oneTimeCode],
        autoDismissKeyboard: true,
        formErrorSpace: 20.h,
        formErrorStyle: AppTextStyles.w400.copyWith(
          color: Styles.ERORR_COLOR,
        ),
        theme: MaterialPinTheme(
          shape: MaterialPinShape.outlined,
          borderRadius: BorderRadius.circular(8.w),
          cellSize: Size(45.w, 45.w),
          focusedBorderColor: Styles.PRIMARY_COLOR,
          filledBorderColor: Styles.PRIMARY_COLOR,
          borderColor: Styles.LIGHT_BORDER_COLOR,
          fillColor: Styles.WHITE_COLOR,
          focusedFillColor: Styles.WHITE_COLOR,
          filledFillColor: Styles.WHITE_COLOR,
          disabledBorderColor: Styles.LIGHT_BORDER_COLOR,
          errorBorderColor: Styles.ERORR_COLOR,
          cursorColor: Styles.PRIMARY_COLOR,
          textStyle: AppTextStyles.w600.copyWith(
            color: Styles.PRIMARY_COLOR,
          ),
          hintStyle: AppTextStyles.w400.copyWith(
            color: Styles.HINT_COLOR,
          ),
        ),
        mainAxisAlignment: MainAxisAlignment.center,
        separatorBuilder: (_, __) => SizedBox(width: 4.w),
      ),
    );
  }
}
