
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../app/core/styles.dart';
import '../app/core/text_styles.dart';

class CustomPinCodeField extends StatelessWidget {
  final void Function(String?)? onSave;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validation;

  const CustomPinCodeField(
      {super.key,
      this.onSave,
      this.validation,
      this.onChanged,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.05),
      child: PinCodeTextField(
        validator: validation,
        cursorColor: Styles.PRIMARY_COLOR,
        backgroundColor: Colors.transparent,
        autoDisposeControllers: false,
        autoDismissKeyboard: true,
        enableActiveFill: true,
        controller: controller,
        enablePinAutofill: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
        textStyle: AppTextStyles.w600.copyWith(
          color: Styles.PRIMARY_COLOR,
        ),
        pastedTextStyle:
            AppTextStyles.w600.copyWith(color: Styles.PRIMARY_COLOR),
        textInputAction: TextInputAction.done,
        pinTheme: PinTheme(
          borderWidth: 1,
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(8.w),
          fieldHeight: 45.w,
          fieldWidth: 45.w,
          fieldOuterPadding: EdgeInsets.symmetric(horizontal: 4.w),
          activeColor: Styles.PRIMARY_COLOR,
          inactiveColor: Styles.LIGHT_BORDER_COLOR,
          selectedColor: Styles.PRIMARY_COLOR,
          activeFillColor: Styles.WHITE_COLOR,
          inactiveFillColor: Styles.WHITE_COLOR,
          selectedFillColor: Styles.WHITE_COLOR,
          disabledColor: Styles.LIGHT_BORDER_COLOR,
          errorBorderColor: Styles.ERORR_COLOR,
        ),
        appContext: context,
        length: 5,
        onSaved: onSave,
        onChanged: (v) {
          onChanged?.call(v);
        },
        // hintCharacter: "ـــــــ",
        hintStyle: AppTextStyles.w400.copyWith(color: Styles.HINT_COLOR),
        errorTextSpace: 20.h,
      ),
    );
  }
}
