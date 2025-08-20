import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../app/core/dimensions.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import '../app/localization/language_constant.dart';
import '../navigation/custom_navigation.dart';
import '../navigation/routes.dart';

class TextOfAgreeTerms extends StatelessWidget {
  const TextOfAgreeTerms({super.key, this.fromWelcomeScreen = true});
  final bool fromWelcomeScreen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
            vertical: Dimensions.paddingSizeExtraSmall.h),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: getTranslated("by_signing_in_you_agree", context: context),
              style: AppTextStyles.w500
                  .copyWith(fontSize: 14, color: Styles.TITLE),
              children: [
                TextSpan(
                    text: getTranslated("terms_of_use", context: context),
                    style: AppTextStyles.w500.copyWith(
                        fontSize: 14,
                        color: Styles.PRIMARY_COLOR,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        CustomNavigator.push(Routes.terms);
                      }),
                TextSpan(
                  text: " ${getTranslated("and", context: context)} ",
                  style: AppTextStyles.w500
                      .copyWith(fontSize: 14, color: Styles.TITLE),
                ),
                TextSpan(
                    text: getTranslated("privacy_policy", context: context),
                    style: AppTextStyles.w500.copyWith(
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
    );
  }
}
