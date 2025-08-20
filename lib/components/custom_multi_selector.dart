import 'package:talent_flow/components/animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/extensions.dart';

import '../app/core/dimensions.dart';
import '../app/core/styles.dart';
import '../app/core/svg_images.dart';
import '../app/core/text_styles.dart';
import 'custom_images.dart';

class CustomMultiSelector extends StatefulWidget {
  const CustomMultiSelector(
      {super.key,
      required this.onConfirm,
      required this.list,
      this.initialValue});
  final ValueChanged<dynamic> onConfirm;
  final List<dynamic> list;
  final List<int>? initialValue;

  @override
  State<CustomMultiSelector> createState() => _CustomMultiSelectorState();
}

class _CustomMultiSelectorState extends State<CustomMultiSelector> {
  List<int>? _selectedItems;
  @override
  void initState() {
    setState(() {
      _selectedItems = widget.initialValue ?? [];
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
            if (_selectedItems!.contains(widget.list[index].id)) {
              setState(() => _selectedItems!
                  .removeWhere((e) => e == widget.list[index].id));
            } else {
              setState(() => _selectedItems!.add(widget.list[index].id));
            }

            widget.onConfirm(widget.list[index]);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL.h),
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
                vertical: Dimensions.PADDING_SIZE_SMALL.h),
            decoration: BoxDecoration(
              color: _selectedItems!.contains(widget.list[index].id)
                  ? Styles.PRIMARY_COLOR
                  : Styles.WHITE_COLOR,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _selectedItems!.contains(widget.list[index].id)
                      ? Styles.WHITE_COLOR
                      : Styles.PRIMARY_COLOR),
            ),
            width: context.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.list[index].title ?? "",
                    style: AppTextStyles.w600.copyWith(
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      color: _selectedItems!.contains(widget.list[index].id)
                          ? Styles.WHITE_COLOR
                          : Styles.PRIMARY_COLOR,
                    ),
                  ),
                ),
                _selectedItems!.contains(widget.list[index].id)
                    ? customImageIconSVG(
                        imageName: SvgImages.checkBox,
                        color: Styles.WHITE_COLOR)
                    : customImageIconSVG(
                        imageName: SvgImages.nonCheckBox,
                        color: Styles.PRIMARY_COLOR),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
