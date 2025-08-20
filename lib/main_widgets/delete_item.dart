import 'package:talent_flow/app/core/images.dart';
import 'package:talent_flow/app/core/text_styles.dart';
import 'package:talent_flow/components/custom_images.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:flutter/material.dart';
import '../../app/core/dimensions.dart';
import '../../app/core/styles.dart';
import '../../app/localization/language_constant.dart';
import '../../components/custom_button.dart';

class DeleteItem extends StatelessWidget {
  const DeleteItem(
      {super.key,
      required this.id,
      required this.isLoading,
      required this.onTap});
  final int id;
  final bool isLoading;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall.w,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: customImageIcon(
              imageName: Images.deleteAlert,
              width: 80.w,
              height: 80.w,
            ),
          ),

          Text(
            getTranslated("delete_item"),
            textAlign: TextAlign.center,
            style: AppTextStyles.w600
                .copyWith(fontSize: 22, color: Styles.IN_ACTIVE),
          ),
          Text(
            getTranslated("are_you_sure_you_want_to_delete_this_item"),
            textAlign: TextAlign.center,
            style:
                AppTextStyles.w400.copyWith(fontSize: 16, color: Styles.HEADER),
          ),
          SizedBox(height: 25.h),

          ///Actions
          Padding(
            padding: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL.h),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: getTranslated("cancel"),
                    height: 45.h,
                    textColor: Styles.TITLE,
                    backgroundColor: Styles.FILL_COLOR,
                    withBorderColor: true,
                    borderColor: Styles.FILL_COLOR,
                    onTap: () {
                      if (!isLoading) {
                        CustomNavigator.pop();
                      }
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomButton(
                      text: getTranslated("yes_delete"),
                      height: 45.h,
                      textColor: Styles.LOGOUT_COLOR,
                      borderColor: Styles.LOGOUT_COLOR,
                      withBorderColor: true,
                      backgroundColor: Styles.WHITE_COLOR,
                      isLoading: isLoading,
                      onTap: onTap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
