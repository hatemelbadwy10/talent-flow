import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:talent_flow/app/core/extensions.dart';
import '../app/core/dimensions.dart';
import '../app/core/images.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import '../app/localization/language_constant.dart';
import '../navigation/custom_navigation.dart';

loadingDialog() {
  return showDialog(
    context: CustomNavigator.navigatorState.currentContext!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.symmetric(
            vertical: Dimensions.PADDING_SIZE_DEFAULT.w,
            horizontal: Dimensions.PADDING_SIZE_DEFAULT.w),
        insetPadding: EdgeInsets.symmetric(
            vertical: Dimensions.PADDING_SIZE_EXTRA_LARGE.w,
            horizontal: context.width * 0.2),
        shape: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(20.0)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(
            Images.appLogo,
            height: MediaQuery.of(context).size.width * .25,
            width: MediaQuery.of(context).size.width * .25,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Dimensions.PADDING_SIZE_DEFAULT.w,
            ),
            child: Text(
              getTranslated("loading"),
              style: AppTextStyles.w500.copyWith(
                fontSize: 16.0,
                color: Styles.HEADER,
              ),
            ),
          ),
        ]),
      );
    },
  );
}

spinKitDialog() {
  showDialog(
      barrierDismissible: false,
      context: CustomNavigator.navigatorState.currentContext!,
      builder: (BuildContext context) {
        return SizedBox(
          height: context.height,
          width: context.width,
          child: const Center(
            child: Center(
              child: SpinKitFadingCircle(
                color: Styles.WHITE_COLOR,
                size: 50,
              ),
            ),
          ),
        );
      });
}
