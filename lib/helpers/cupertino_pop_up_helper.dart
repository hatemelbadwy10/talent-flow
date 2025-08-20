import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import '../app/localization/language_constant.dart';
import '../navigation/custom_navigation.dart';

abstract class CupertinoPopUpHelper {
  static showCupertinoTextController(
      {required TextEditingController controller,
      required String title,
      required String description,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      Function()? onSend,
      Function()? onClose}) {
    showDialog(
      context: CustomNavigator.navigatorState.currentContext!,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Center(child: Text(title)),
          content: Column(
            children: [
              Text(
                description,
                style: AppTextStyles.w400.copyWith(fontSize: 13),
              ),
              CupertinoTextField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                decoration: BoxDecoration(
                    color: const Color(0xFF767680).withOpacity(.12),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
                onPressed: () {
                  if (onClose != null) {
                    onClose();
                  } else {
                    CustomNavigator.pop();
                  }
                },
                child: Text(
                  getTranslated("cancel"),
                  style: AppTextStyles.w400
                      .copyWith(fontSize: 17, color: Styles.SYSTEM_COLOR),
                )),
            CupertinoDialogAction(
                onPressed: onSend,
                child: Text(
                  getTranslated("send"),
                  style: AppTextStyles.w600
                      .copyWith(fontSize: 17, color: Styles.SYSTEM_COLOR),
                )),
          ],
        );
      },
    ).then((value) => onClose);
  }
}
