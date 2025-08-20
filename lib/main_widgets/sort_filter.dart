import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/localization/language_constant.dart';
import 'package:talent_flow/main_models/custom_field_model.dart';

import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import '../components/custom_button.dart';
import '../components/custom_single_selector.dart';
import '../navigation/custom_navigation.dart';

class SortFilter extends StatelessWidget {
  const SortFilter(
      {super.key,
      required this.onSelect,
      this.onConfirm,
      this.onCancel,
      this.onClear,
      this.initialValue});
  final Function(CustomFieldModel?) onSelect;
  final Function()? onConfirm, onCancel, onClear;
  final int? initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              borderRadius: BorderRadius.circular(100)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.PADDING_SIZE_DEFAULT.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getTranslated("sort_by"),
                style: AppTextStyles.w700.copyWith(
                  fontSize: 18,
                ),
              ),
              GestureDetector(
                onTap: () {
                  CustomNavigator.pop();
                  onClear?.call();
                },
                child: const Icon(
                  Icons.clear,
                  size: 24,
                  color: Styles.DISABLED,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: 8.h, horizontal: Dimensions.PADDING_SIZE_DEFAULT.w),
          child: const Divider(
            color: Styles.BORDER_COLOR,
          ),
        ),
        Expanded(
          child: CustomSingleSelector(
            initialValue: initialValue,
            onConfirm: (v) => onSelect(v),
            list: [
              CustomFieldModel(
                  id: 0,
                  name: getTranslated("price_low_to_high"),
                  code: "price_low_to_high,"),
              CustomFieldModel(
                  id: 1,
                  name: getTranslated("price_high_to_low"),
                  code: "price_high_to_low,"),
              CustomFieldModel(
                  id: 2, name: getTranslated("newest"), code: "newest,"),
              CustomFieldModel(
                  id: 3, name: getTranslated("oldest"), code: "oldest,"),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
                vertical: Dimensions.paddingSizeExtraSmall.h),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: getTranslated("apply"),
                    onTap: onConfirm,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    text: getTranslated("cancel"),
                    backgroundColor: Styles.FILL_COLOR,
                    textColor: Styles.TITLE,
                    onTap: onCancel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
