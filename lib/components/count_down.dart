import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import '../app/localization/language_constant.dart';

class CountDown extends StatefulWidget {
  const CountDown({super.key, this.timeBySecond = 60, this.onCount});
  final int timeBySecond;
  final Function? onCount;

  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  late Timer _timer;
  int _count = 0;
  @override
  void initState() {
    countDown();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  countDown() {
    setState(() => _count = widget.timeBySecond);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_count != 0) {
        setState(() => --_count);
      } else {
        if (_timer.isActive) _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
          text: getTranslated("didn't_receive_the_code"),
          style: AppTextStyles.w500.copyWith(
              color: Styles.DETAILS_COLOR,
              fontSize: 14,
              overflow: TextOverflow.ellipsis),
          children: [
            TextSpan(
                text: " ${getTranslated("resend_code")}",
                style: AppTextStyles.w500.copyWith(
                  fontSize: 14,
                  color: (_count == 0)
                      ? Styles.PRIMARY_COLOR
                      : Styles.DETAILS_COLOR,
                  // decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (_count == 0) {
                      countDown();
                      if (widget.onCount != null) {
                        widget.onCount!();
                      }
                    }
                  }),
            if (_count != 0)
              TextSpan(
                  text:
                      " (${Duration(seconds: _count).inMinutes.remainder(60).toString().padLeft(2, '0')}:${Duration(seconds: _count).inSeconds.remainder(60).toString().padLeft(2, '0')})",
                  style: AppTextStyles.w500.copyWith(
                      // decoration: TextDecoration.underline,
                      color: _count == 0
                          ? Styles.PRIMARY_COLOR
                          : Styles.DETAILS_COLOR,
                      fontSize: 14)),
          ]),
    );
  }
}
