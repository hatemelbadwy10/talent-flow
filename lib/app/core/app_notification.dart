import 'package:flutter/material.dart';

class AppNotification {
  final String message;
  final String? iconName;
  final Color backgroundColor;
  final Color borderColor;
  final bool isFloating;
  late final double radius;
  final Widget? action;
  final bool withAction;
  final void Function()? onVisible;
  AppNotification(
      {required this.message,
        this.onVisible,
        this.iconName,
        this.backgroundColor = Colors.black,
        this.borderColor = Colors.transparent,
        this.isFloating = false,
        this.withAction = false,
        this.action,
        double? radius}) {
    this.radius = radius ?? (isFloating ? 15 : 0);
  }
}
