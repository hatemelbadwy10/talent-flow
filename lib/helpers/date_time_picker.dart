import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/animated_widget.dart';
import '../../navigation/custom_navigation.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import '../components/custom_button.dart';

class DateTimePicker extends StatefulWidget {
  final String? initialString;
  final String? format;
  final bool? isNotEmptyValue;
  final DateTime? startDateTime;
  final DateTime? minDateTime;
  final ValueChanged<DateTime>? valueChanged;
  final String label;
  final CupertinoDatePickerMode? mode;

  const DateTimePicker(
      {super.key,
      this.mode,
      this.initialString,
      this.minDateTime,
      this.format,
      required this.valueChanged,
      this.isNotEmptyValue = false,
      this.startDateTime,
      required this.label});

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime? date;

  @override
  void initState() {
    setState(() {
      if (widget.isNotEmptyValue!) {
        date = DateTime.parse(widget.initialString!);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                borderRadius: BorderRadius.circular(100)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: AppTextStyles.w700.copyWith(
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    CustomNavigator.pop();
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
          Flexible(
              child: ListAnimator(
            controller: ScrollController(),
            customPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
                vertical: Dimensions.paddingSizeMini.h),
            data: [
              SizedBox(
                height: 250.h,
                child: CupertinoDatePicker(
                    mode: widget.mode ?? CupertinoDatePickerMode.date,
                    onDateTimeChanged: (value) => date = value,
                    initialDateTime:
                        date ?? widget.startDateTime ?? DateTime.now(),
                    minimumDate: widget.minDateTime != null
                        ? DateTime(widget.minDateTime!.year,
                            widget.minDateTime!.month, widget.minDateTime!.day)
                        : widget.startDateTime != null
                            ? DateTime(
                                widget.startDateTime!.year,
                                widget.startDateTime!.month,
                                widget.startDateTime!.day)
                            : DateTime(1900),
                    maximumDate: DateTime(2100)),
              )
            ],
          )),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
                  vertical: Dimensions.paddingSizeExtraSmall.h),
              child: CustomButton(
                text: 'confirm',
                onTap: () {
                  if (date != null) {
                    widget.valueChanged!(date!);
                    CustomNavigator.pop();
                  } else {
                    widget
                        .valueChanged!(widget.startDateTime ?? DateTime.now());
                    CustomNavigator.pop();
                  }
                },
                backgroundColor: Styles.PRIMARY_COLOR,
                textColor: Styles.WHITE_COLOR,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
