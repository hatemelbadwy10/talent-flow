import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';

import '../app/core/text_styles.dart';
import '../app/localization/language_constant.dart';
import '../navigation/custom_navigation.dart';
import '../navigation/routes.dart';

class AgreeToTerms extends StatelessWidget {
  const AgreeToTerms({
    super.key,
    this.check = true,
    required this.onChange,
  });
  final bool check;
  final Function(bool) onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: Dimensions.PADDING_SIZE_DEFAULT.h,
          bottom: Dimensions.paddingSizeMini.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: check,
            onChanged: (v) => onChange(!check),
            activeColor: Styles.PRIMARY_COLOR,
            side: BorderSide(color: Styles.PRIMARY_COLOR),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: "${getTranslated("i_agree_to")} ",
                  style: AppTextStyles.w500
                      .copyWith(fontSize: 14, color: Styles.TITLE),
                  children: [
                    TextSpan(
                        text: getTranslated("terms_conditions"),
                        style: AppTextStyles.w600.copyWith(
                            fontSize: 14,
                            color: Styles.PRIMARY_COLOR,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            CustomNavigator.push(Routes.terms);
                          }),
                    TextSpan(
                      text: " & ",
                      style: AppTextStyles.w500
                          .copyWith(fontSize: 14, color: Styles.TITLE),
                    ),
                    TextSpan(
                        text: getTranslated("privacy_policy"),
                        style: AppTextStyles.w600.copyWith(
                            fontSize: 14,
                            color: Styles.PRIMARY_COLOR,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            CustomNavigator.push(Routes.privacy);
                          }),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
