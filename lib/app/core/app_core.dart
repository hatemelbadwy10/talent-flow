import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/core/text_styles.dart';
import '../../../navigation/custom_navigation.dart';
import '../localization/language_constant.dart';
import 'app_notification.dart';
import 'styles.dart';

class AppCore {
  static showSnackBar({required AppNotification notification}) {
    Timer(Duration.zero, () {
      CustomNavigator.scaffoldState.currentState!.showSnackBar(
        SnackBar(
          padding: const EdgeInsets.all(0),
          duration: const Duration(seconds: 2),
          behavior: notification.isFloating
              ? SnackBarBehavior.floating
              : SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(notification.radius),
              side: BorderSide(width: 1, color: notification.borderColor)),
          margin: notification.isFloating ? EdgeInsets.all(24.w) : null,
          onVisible: notification.onVisible,
          content: SizedBox(
            height: notification.withAction ? null : 60.h,
            child: Row(
              children: [
                if (notification.iconName != null)
                  Image.asset(
                    notification.iconName!,
                    height: 20.h,
                    width: 20.w,
                  ),
                if (notification.iconName == null) SizedBox(width: 24.w),
                Expanded(
                  child: Text(
                    notification.message,
                    style: AppTextStyles.w600.copyWith(fontSize: 13),
                  ),
                ),
                if (notification.withAction)
                  notification.action ?? const SizedBox(),
              ],
            ),
          ),
          backgroundColor: notification.backgroundColor,
        ),
      );
    });
  }

  static hideSnackBar() {
    CustomNavigator.scaffoldState.currentState!
        .hideCurrentSnackBar(reason: SnackBarClosedReason.remove);
  }

  static Future<String> getAppFilePath() async {
    String? path;
    if (Platform.isAndroid) {
      path =
          '${await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD)}/talent_flow';
    } else {
      Directory documents = await getApplicationDocumentsDirectory();
      path = '${documents.path}/talent_flow';
    }

    return path;
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  static showToast(msg,
      {Color? backGroundColor, Color? textColor, Toast? toastLength}) {
    return Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: backGroundColor ?? Colors.black,
        textColor: textColor ?? Styles.WHITE_COLOR,
        fontSize: 16.0);
  }

  successMotionToast(msg, {Alignment? position, AnimationType? animationType}) {
    return MotionToast.success(
      title: Text(
        getTranslated("success"),
        style: AppTextStyles.w600.copyWith(fontSize: 13, color: Styles.ACTIVE),
      ),
      description: Text(
        msg,
        style: AppTextStyles.w400.copyWith(fontSize: 11, color: Styles.ACTIVE),
      ),
      height: 70.h,
      width: CustomNavigator.navigatorState.currentContext!.width - 60.w,
      layoutOrientation: TextDirection.ltr,
      animationType: animationType ?? AnimationType.slideInFromTop,
      toastAlignment: position ?? Alignment.topCenter,
    ).show(CustomNavigator.navigatorState.currentContext!);
  }

  errorMotionToast(msg, {Alignment? position, AnimationType? animationType}) {
    return MotionToast.error(
      title: Text(
        getTranslated("error"),
        style:
            AppTextStyles.w600.copyWith(fontSize: 13, color: Styles.IN_ACTIVE),
      ),
      description: Text(
        msg,
        style:
            AppTextStyles.w400.copyWith(fontSize: 11, color: Styles.IN_ACTIVE),
      ),
      height: 70.h,
      width: CustomNavigator.navigatorState.currentContext!.width - 60.w,
      layoutOrientation: TextDirection.ltr,
      animationType: animationType ?? AnimationType.slideInFromTop,
      toastAlignment: position ?? Alignment.topCenter,
    ).show(CustomNavigator.navigatorState.currentContext!);
  }

  static bool scrollListener(
      ScrollController controller, int maxPage, int currentPage) {
    double maxScroll = controller.position.maxScrollExtent;
    double currentScroll = controller.position.pixels;
    if (maxScroll == currentScroll && maxScroll != 0.0) {
      log(">>>>>>>>>>>>>>> get into equal scroll");
      log('$maxScroll   $currentScroll');
      if (currentPage < maxPage) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  static shareDetails({String? details}) async {
    await Share.share(
      '${dotenv.env['DOMAIN'] ?? ""}$details',
    );
  }
}
