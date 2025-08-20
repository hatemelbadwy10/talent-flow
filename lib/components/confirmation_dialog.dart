import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/localization/language_constant.dart';
import 'package:flutter/material.dart';
import '../../navigation/custom_navigation.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import 'custom_button.dart';
import 'custom_images.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog(
      {required this.txtBtn,
      this.txtBtn2,
      this.title,
      this.image,
      this.description,
      this.withOneButton = true,
      this.isSvg = true,
      this.imageColor,
      this.textColor,
      this.backgroundColor,
      this.onContinue,
      super.key});
  final void Function()? onContinue;
  final String txtBtn;
  final Color? imageColor, textColor, backgroundColor;
  final bool withOneButton, isSvg;
  final String? image, title, description, txtBtn2;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
            visible: image != null,
            child: isSvg
                ? customContainerSvgIcon(
                    imageName: image ?? "",
                    height: 80.h,
                    width: 80.h,
                    radius: 100,
                    padding: 16.h,
                    color: imageColor ?? Styles.PRIMARY_COLOR)
                : customContainerImage(
                    imageName: image ?? "",
                    height: 80.h,
                    width: 80.h,
                    radius: 100,
                    color: imageColor ?? Styles.PRIMARY_COLOR)),
        Visibility(
          visible: title != null,
          child: Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
            child: Text(
              title ?? "",
              textAlign: TextAlign.center,
              style: AppTextStyles.w600
                  .copyWith(fontSize: 22, color: Styles.TITLE),
            ),
          ),
        ),
        Visibility(
          visible: description != null,
          child: Text(
            description ?? "",
            textAlign: TextAlign.center,
            style: AppTextStyles.w400
                .copyWith(fontSize: 14, color: Styles.DETAILS_COLOR),
          ),
        ),
        SizedBox(height: 24.h),
        withOneButton
            ? CustomButton(
                onTap: onContinue,
                text: txtBtn,
                textColor: textColor,
                backgroundColor: backgroundColor,
                height: 45.h,
              )
            : Row(
                children: [
                  Expanded(
                      child: CustomButton(
                    onTap: onContinue,
                    text: txtBtn,
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    height: 45.h,
                  )),
                  SizedBox(
                    width: 16.w,
                  ),
                  Expanded(
                      child: CustomButton(
                    onTap: () => CustomNavigator.pop(),
                    text: txtBtn2 ?? getTranslated("cancel"),
                    backgroundColor: Styles.PRIMARY_COLOR.withOpacity(0.1),
                    textColor: Styles.PRIMARY_COLOR,
                  ))
                ],
              )
      ],
    );
  }
}
