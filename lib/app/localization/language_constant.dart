import 'package:flutter/cupertino.dart';

import '../../navigation/custom_navigation.dart';
import 'app_localization.dart';

String getTranslated(String key, {BuildContext? context}) {
  return AppLocalization.of(
          context ?? CustomNavigator.navigatorState.currentContext!)!
      .translate(key);
}
