import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import '../app/localization/language_constant.dart';
import '../navigation/custom_navigation.dart';
import 'custom_button.dart';

abstract class CustomBottomSheet {
  static show({
    Function()? onConfirm,
    Function()? onCancel,
    String? label,
    String? buttonText,
    required Widget widget,
    double? height,
    Widget? child,
    bool? isLoading,
    bool withPadding = true,
    bool withCancel = true,
    Function()? onDismiss,
    Function()? onClose,
  }) {
    return showMaterialModalBottomSheet(
      enableDrag: true,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      context: CustomNavigator.navigatorState.currentContext!,
      expand: false,
      useRootNavigator: true,
      isDismissible: true,
      builder: (_) {
        return Padding(
          padding:
              MediaQuery.of(
                CustomNavigator.navigatorState.currentContext!,
              ).viewInsets,
          child: Container(
            width: CustomNavigator.navigatorState.currentContext!.width,
            constraints:
                height != null ? BoxConstraints(maxHeight: height) : null,
            decoration: BoxDecoration(
              color: Styles.WHITE_COLOR,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.w),
                topLeft: Radius.circular(30.w),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60.w,
                  height: 4.h,
                  margin: EdgeInsets.only(
                    left: Dimensions.PADDING_SIZE_DEFAULT.w,
                    right: Dimensions.PADDING_SIZE_DEFAULT.w,
                    top: Dimensions.paddingSizeMini.h,
                    bottom: Dimensions.PADDING_SIZE_DEFAULT.h,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Styles.HINT_COLOR,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                if (label != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.w700.copyWith(fontSize: 18),
                        ),
                        GestureDetector(
                          onTap: () {
                            CustomNavigator.pop();
                            onDismiss?.call();
                          },
                          child: const Icon(
                            Icons.clear,
                            size: 24,
                            color: Styles.DISABLED,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (label != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
                    ),
                    child: const Divider(color: Styles.BORDER_COLOR),
                  ),
                Flexible(child: widget),
                Visibility(
                  visible: child != null || onConfirm != null,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
                        vertical: Dimensions.paddingSizeExtraSmall.h,
                      ),
                      child:
                          child ??
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: getTranslated(buttonText ?? "confirm"),
                                  isLoading: isLoading ?? false,
                                  onTap: onConfirm,
                                ),
                              ),
                              if (withCancel) SizedBox(width: 8.w),
                              if (withCancel)
                                Expanded(
                                  child: CustomButton(
                                    text: getTranslated("cancel"),
                                    backgroundColor: Styles.FILL_COLOR,
                                    textColor: Styles.TITLE,
                                    onTap:
                                        onCancel ?? () => CustomNavigator.pop(),
                                  ),
                                ),
                            ],
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) => onClose?.call());
  }

  static general({
    Function()? onConfirm,
    double? height,
    bool canDismiss = false,
    required Widget? widget,
    Function()? onDismiss,
    Function()? onClose,
  }) {
    return showMaterialModalBottomSheet(
      enableDrag: true,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      context: CustomNavigator.navigatorState.currentContext!,
      expand: false,
      useRootNavigator: true,
      isDismissible: canDismiss,
      builder: (_) {
        return Padding(
          padding:
              MediaQuery.of(
                CustomNavigator.navigatorState.currentContext!,
              ).viewInsets,
          child: Container(
            constraints:
                height != null ? BoxConstraints(maxHeight: height) : null,
            width: CustomNavigator.navigatorState.currentContext!.width,
            decoration: BoxDecoration(
              color: Styles.WHITE_COLOR,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.w),
                topLeft: Radius.circular(30.w),
              ),
            ),
            child: widget,
          ),
        );
      },
    ).then((value) => onClose?.call());
  }
}
