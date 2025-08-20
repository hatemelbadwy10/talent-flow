import 'dart:developer';
import 'dart:io';
import 'package:talent_flow/app/core/text_styles.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../app/core/styles.dart';
import '../app/localization/language_constant.dart';

abstract class CheckOnTheVersion {
  static String appStoreUrl =
      'https://apps.apple.com/eg/app/blue-art/id6670496496';

  static Future<String> getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String> getLiveVersionIOS() async {
    final response = await http.get(Uri.parse(
        'https://itunes.apple.com/lookup?bundleId=com.talent_flow.app'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log("===> IOS data $data");
      if (data['resultCount'] > 0) {
        return data['results'][0]['version'];
      }
    }
    throw Exception('Failed to fetch live version');
  }

  static checkOnIOSVersion() async {
    String? iosCurrentVersion = await getCurrentVersion();
    String? iosLiveVersion = await getLiveVersionIOS();
    if (iosCurrentVersion != iosLiveVersion) {
      showDialog(
        context: CustomNavigator.navigatorState.currentContext!,
        barrierDismissible: false,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text(
              getTranslated("new_update_available"),
              textAlign: TextAlign.center,
              style: AppTextStyles.w600
                  .copyWith(fontSize: 16, color: Styles.HEADER),
            ),
            content: Text(
              getTranslated("new_update_available_desc"),
              textAlign: TextAlign.center,
              style: AppTextStyles.w400
                  .copyWith(fontSize: 14, color: Styles.HEADER),
            ),
            actions: [
              CupertinoDialogAction(
                  child: Text(getTranslated("update_now")),
                  onPressed: () async {
                    await launchUrl(Uri.parse(appStoreUrl));
                    CustomNavigator.pop();
                  }),
              CupertinoDialogAction(
                  child: Text(getTranslated("later")),
                  onPressed: () => CustomNavigator.pop()),
            ],
          );
        },
      );
    }
  }

  static checkOnAndroidVersion() async {
    await InAppUpdate.checkForUpdate().then(
      (value) async {
        if (value.updateAvailability == UpdateAvailability.updateAvailable) {
          await InAppUpdate.startFlexibleUpdate();
        }
      },
    );
  }

  static checkOnVersion() async {
    if (Platform.isIOS) {
      return checkOnIOSVersion();
    } else {
      return checkOnAndroidVersion();
    }
  }
}
