import 'package:talent_flow/app/localization/language_constant.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:flutter/material.dart';
import '../app/core/dimensions.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import '../main_models/custom_field_model.dart';

class CustomSingleSelector extends StatefulWidget {
  const CustomSingleSelector(
      {super.key,
      required this.onConfirm,
      required this.list,
      this.withTranslate = false,
      this.initialValue});
  final ValueChanged<CustomFieldModel?> onConfirm;
  final List<CustomFieldModel> list;
  final int? initialValue;
  final bool withTranslate;

  @override
  State<CustomSingleSelector> createState() => _CustomSingleSelectorState();
}

class _CustomSingleSelectorState extends State<CustomSingleSelector> {
  int? _selectedItem;
  @override
  void initState() {
    setState(() {
      _selectedItem = widget.initialValue;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListAnimator(
      controller: ScrollController(),
      customPadding:
          EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT.w),
      data: List.generate(
        widget.list.length,
        (index) => GestureDetector(
          onTap: () {
            setState(() => _selectedItem = widget.list[index].id);
            widget.onConfirm(widget.list[index]);
          },
          child: Container(
            // margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL.h),
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
                vertical: Dimensions.PADDING_SIZE_SMALL.h),
            decoration: BoxDecoration(
              // color: _selectedItem == widget.list[index].id
              //     ? Styles.PRIMARY_COLOR
              //     : Styles.WHITE_COLOR,
              // borderRadius: BorderRadius.circular(12),
              border: Border(
                bottom: BorderSide(
                    color: (widget.list.length - 1) == index
                        ? Colors.transparent
                        : Styles.LIGHT_BORDER_COLOR),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    _selectedItem == widget.list[index].id
                        ? Icons.radio_button_checked_outlined
                        : Icons.radio_button_off,
                    size: 22,
                    color: _selectedItem == widget.list[index].id
                        ? Styles.PRIMARY_COLOR
                        : Styles.HINT_COLOR),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.withTranslate == true
                        ? getTranslated(widget.list[index].name ?? "")
                        : widget.list[index].name ?? "",
                    style: AppTextStyles.w600.copyWith(
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      color: Styles.HEADER,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
