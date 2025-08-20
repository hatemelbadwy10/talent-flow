import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/localization/language_constant.dart';
import 'package:flutter/material.dart';

import '../app/core/styles.dart';
import '../app/core/text_styles.dart';

class CreateRequestSuccessDialog extends StatelessWidget {
  const CreateRequestSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height,
      width: context.width,
      color: Styles.WHITE_COLOR,
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
          vertical: Dimensions.PADDING_SIZE_DEFAULT.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_sharp,
              color: Styles.PRIMARY_COLOR, size: 100),
          Padding(
            padding: EdgeInsets.only(
                top: Dimensions.PADDING_SIZE_EXTRA_LARGE.h,
                bottom: Dimensions.paddingSizeExtraSmall.h),
            child: Text(
              getTranslated("submitted_successfully"),
              textAlign: TextAlign.center,
              style: AppTextStyles.w600.copyWith(
                  fontSize: 24,
                  color: Styles.HEADER,
                  decoration: TextDecoration.none),
            ),
          ),
          Text(
            getTranslated(
                "we_have_sent_to_all_talents_a_request_that_you_offer"),
            textAlign: TextAlign.center,
            style: AppTextStyles.w400.copyWith(
                fontSize: 18,
                color: Styles.DETAILS_COLOR,
                decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}
