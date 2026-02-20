import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dimensions.dart';
import 'styles.dart';
import 'text_styles.dart';


extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  Color get toColor {
    String colorStr = this;
    colorStr = "FF$colorStr";
    colorStr = colorStr.replaceAll("#", "");
    int val = 0;
    int len = colorStr.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = colorStr.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw const FormatException(
            "An error occurred when converting a color");
      }
    }
    return Color(val);
  }

  String hiddenNumber() {
    return this[length - 2] + this[length - 1] + List.filled(length - 2, '*').join();
  }
}

extension DateExtention on DateTime {
  String dateFormat({required String format, String? lang}) {
    return DateFormat(
            format, lang)
        .format(this);
  }

  String arTimeFormat() {
    return DateFormat("hh,mm aa").format(this);
  }
}

extension DefaultFormat on DateTime {
  String defaultFormat() {
    return DateFormat("d MMM yyyy").format(this);
  }

  String defaultFormat2() {
    return DateFormat("d/M/yyyy").format(this);
  }
}

String localeCode = "en";

extension ConvertDigits on String {
  String convertDigits() {
    var sb = StringBuffer();
    if (localeCode == "en") {
      return this;
    } else {
      for (int i = 0; i < length; i++) {
        switch (this[i]) {
          case '0':
            sb.write('٠');
            break;
          case '1':
            sb.write('۱');
            break;
          case '2':
            sb.write('۲');
            break;
          case '3':
            sb.write('۳');
            break;
          case '4':
            sb.write('٤');
            break;
          case '5':
            sb.write('٥');
            break;
          case '6':
            sb.write('٦');
            break;
          case '7':
            sb.write('٧');
            break;
          case '8':
            sb.write('۸');
            break;
          case '9':
            sb.write('۹');
            break;
          default:
            sb.write(this[i]);
            break;
        }
      }
    }
    return sb.toString();
  }
}

extension MediaQueryValues on BuildContext {
  double get height => MediaQuery.of(this).size.height;

  double get width => MediaQuery.of(this).size.width;

  double get toPadding => MediaQuery.of(this).viewPadding.top;

  double get bottom => MediaQuery.of(this).viewInsets.bottom;
}
// Widget Extensions



Duration transitionDuration = const Duration(milliseconds: 300);

extension WidgetExtension on Widget {
  /// set container to view
  Widget setContainerToView({
    double? height,
    double? width,
    double? margin,
    double? padding,
    double? radius,
    Color? color,
    Color? borderColor,
    AlignmentGeometry? alignment,
    List<BoxShadow>? shadows,
    Gradient? gradient,
  }) {
    return AnimatedContainer(
      duration: transitionDuration,
      width: width,
      height: height,
      alignment: alignment,
      margin: EdgeInsets.all(margin ?? 0),
      padding: EdgeInsets.all(padding ?? 0),
      decoration: ShapeDecoration(
        gradient: gradient,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
          side: borderColor != null ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
        ),
        shadows: shadows,
      ),
      child: Material(type: MaterialType.transparency, child: this),
    );
  }

  Widget setMainContainer({double? padding}) {
    return setInkContainerToView(padding: padding ?? 16, radius: Dimensions.RADIUS_LARGE, color: Colors.white);
  }

  Widget setInkContainerToView({
    double? height,
    double? width,
    double? margin,
    double? padding,
    double? radius,
    Color? color,
    Color? borderColor,
    AlignmentGeometry? alignment,
    List<BoxShadow>? shadows,
  }) {
    return Ink(
      decoration: ShapeDecoration(
        color: color,
        shadows: shadows,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
          side: borderColor != null ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
        ),
      ),
      child: AnimatedContainer(
        duration: transitionDuration,
        width: width,
        height: height,
        alignment: alignment,
        padding: EdgeInsets.all(padding ?? 0),
        child: this,
      ),
    );
  }

  Widget setInk({
    double? height,
    double? width,
    double? margin,
    double? padding,
    double? radius,
    Color? color,
    Color? borderColor,
    AlignmentGeometry? alignment,
    List<BoxShadow>? shadows,
  }) {
    return Ink(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding ?? 0),
      decoration: ShapeDecoration(
        color: color,
        shadows: shadows,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
          side: borderColor != null ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
        ),
      ),
      child: this,
    );
  }

  Widget setMaterial() {
    return Material(color: Colors.transparent, type: MaterialType.transparency, child: this);
  }

  Widget circle({
    double radius = 24,
    double borderWidth = 0,
    Color? backgroundColor,
    Color? borderColor,
    Widget? child,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Styles.PRIMARY_COLOR.withValues(alpha: 0.1),
      foregroundColor: borderColor,
      child: child ?? this,
    );
  }

  ClipRRect withGlassEffect({
    double? height,
    double? width,
    Color? color,
    bool hasBorder = true,
    double radius = 16,
    double padding = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
        child: Container(
          height: height,
          width: width,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(radius),
            border: hasBorder ? Border.all(color: color ?? Colors.white.withValues(alpha: 0.6), width: 1) : null,
          ),
          child: this,
        ),
      ),
    );
  }

  Widget setTitle({
    String? title,
    Widget? titleWidget,
    Widget? titleIcon,
    double? fontSize,
    TextStyle? titleStyle,
    double gap = 8,
    double titlePadding = 0,
  }) {
    return title != null || titleWidget != null
        ? Column(
            spacing: gap,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titleWidget ?? Text(title ?? '', style: titleStyle ?? AppTextStyles.w400.copyWith(fontSize: 14)),
                  titleIcon ?? const SizedBox.shrink(),
                ],
              ).paddingHorizontal(titlePadding),
              this,
            ],
          )
        : this;
  }

  Widget withSeeAllTitle({String? title, void Function()? onTap}) {
    return setTitle(
      title: title,
      titlePadding: Dimensions.PADDING_SIZE_DEFAULT,
      titleStyle: AppTextStyles.w600.copyWith(fontSize: 16),
      titleIcon: const Text('See all').clickable(onTap: () => onTap?.call(), style: AppTextStyles.w600.copyWith(fontSize: 12)),
    );
  }

  Widget setSvgToView({required String svgPath, Color? color, double size = 24, double gap = 8, bool isEnd = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isEnd) this,
        if (isEnd) SizedBox(width: gap),
        SvgPicture.asset(svgPath, height: size, width: size, colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null),
        if (!isEnd) SizedBox(width: gap),
        if (!isEnd) Expanded(child: SizedBox()),
      ],
    );
  }

  Widget setBullet({Color? bulletColor, double size = 4, double indent = 4}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(radius: size, backgroundColor: bulletColor),
        SizedBox(width: indent),
        Flexible(child: SizedBox()),
      ],
    );
  }

  /// set visibility
  Widget visible(bool visible, {Widget? fallback}) {
    return visible ? this : (fallback ?? const SizedBox.shrink());
  }

  Widget setBorder({double? width, Color? color, double radius = 0, double padding = 0}) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(color: color ?? Styles.BORDER_COLOR, width: width ?? 1),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: this,
    );
  }

  Widget setCircleBorder({double? width, Color? color, double padding = 0}) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(color: color ?? Styles.BORDER_COLOR, width: width ?? 1),
        shape: BoxShape.circle,
      ),
      child: this,
    );
  }

  /// add custom corner radius each side
  ClipRRect clipRRectOnly({double bottomEnd = 0, double bottomStart = 0, double topEnd = 0, double topStart = 0}) {
    return ClipRRect(
      borderRadius: BorderRadiusDirectional.only(
        bottomEnd: Radius.circular(bottomEnd.toDouble()),
        bottomStart: Radius.circular(bottomStart.toDouble()),
        topEnd: Radius.circular(topEnd.toDouble()),
        topStart: Radius.circular(topStart.toDouble()),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: this,
    );
  }

  /// add corner radius
  ClipRRect clipRRect(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: this,
    );
  }

  ClipRRect clipRRectTop(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: this,
    );
  }

  ClipRRect clipRRectBottom(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(radius), bottomRight: Radius.circular(radius)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: this,
    );
  }

  ClipRRect clipRRectStart(double radius) {
    return ClipRRect(
      borderRadius: BorderRadiusDirectional.horizontal(start: Radius.circular(radius)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: this,
    );
  }

  ClipRRect clipRRectEnd(double radius) {
    return ClipRRect(
      borderRadius: BorderRadiusDirectional.horizontal(end: Radius.circular(radius)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: this,
    );
  }

  ClipRRect clipRRectOnlyWithBorder({
    double bottomLeft = 0,
    double bottomRight = 0,
    double topLeft = 0,
    double topRight = 0,
    Color? borderColor,
    double borderWidth = 1,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(bottomLeft.toDouble()),
        bottomRight: Radius.circular(bottomRight.toDouble()),
        topLeft: Radius.circular(topLeft.toDouble()),
        topRight: Radius.circular(topRight.toDouble()),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.transparent, width: borderWidth),
        ),
        child: this,
      ),
    );
  }

  /// set parent widget in center
  Widget center({double? heightFactor, double? widthFactor, bool enabled = true}) {
    return enabled ? Center(heightFactor: heightFactor, widthFactor: widthFactor, child: this) : this;
  }

  /// add tap to parent widget
  Widget onTap(
    void Function()? function, {
    Color? splashColor,
    Color? hoverColor,
    Color? highlightColor,
    BorderRadius? borderRadius,
    bool isTransparent = false,
    Color? overlayColor,
  }) {
    return InkWell(
      onTap: function,
      splashColor: isTransparent ? Colors.transparent : splashColor,
      hoverColor: isTransparent ? Colors.transparent : hoverColor,
      highlightColor: isTransparent ? Colors.transparent : highlightColor,
      borderRadius: borderRadius,
      overlayColor: WidgetStateProperty.all(overlayColor),
      child: this,
    );
  }

  /// Wrap with ShaderMask widget
  Widget withShaderMask(List<Color> colors, {BlendMode blendMode = BlendMode.srcATop}) {
    return withShaderMaskGradient(LinearGradient(colors: colors), blendMode: blendMode);
  }

  /// Wrap with ShaderMask widget Gradient
  Widget withShaderMaskGradient(Gradient gradient, {BlendMode blendMode = BlendMode.srcATop}) {
    return ShaderMask(shaderCallback: (rect) => gradient.createShader(rect), blendMode: blendMode, child: this);
  }

  /// Validate given widget is not null and returns given value if null.
  Widget validate({Widget value = const SizedBox()}) => this;

  Widget buildWhen(bool value) => value ? this : const SizedBox.shrink();

  Widget withTooltip({required String msg}) => Tooltip(message: msg, child: this);

  Widget withSafeArea({EdgeInsets? minimum}) => SafeArea(minimum: minimum ?? EdgeInsets.zero, child: this);

  Widget bottomSafeArea({EdgeInsets? minimum}) => SafeArea(
    minimum: EdgeInsets.only(left: Dimensions.PADDING_SIZE_DEFAULT, right: Dimensions.PADDING_SIZE_DEFAULT, bottom: 16),
    child: this,
  );

  /// Make your any widget refreshable with RefreshIndicator on top
  // Widget get makeRefreshable => Stack(children: [ListView(), this]);
  RefreshIndicator makeRefreshable(Future<void> Function() onRefresh, {EdgeInsetsGeometry? padding}) {
    return RefreshIndicator.adaptive(
      backgroundColor: Colors.white,
      color: Styles.PRIMARY_COLOR,
      onRefresh: () {
        HapticFeedback.lightImpact();
        return onRefresh();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding ?? EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT, vertical: 16),
        children: [this],
      ),
    );
  }

  Widget withShimmer({
    Duration duration = const Duration(seconds: 1),
    Color? baseColor,
    Color? highlightColor,
    bool buildWhen = true,
  }) {
    if (!buildWhen) return this;
    return Shimmer.fromColors(
      period: duration,
      direction: ShimmerDirection.ltr,
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: this,
    );
  }

  Widget toBottomNavBar({double? bottom, Color? color, Color? borderColor, List<BoxShadow>? shadows}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [this])
        .withSafeArea(minimum: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT).copyWith(bottom: bottom))
        .paddingTop(8)
        .setContainerToView(
          color: color ?? Colors.white,
          borderColor: borderColor,
          shadows: shadows,
        );
  }

  Widget toSuffixIcon({double width = 0}) {
    return SizedBox(width: width, child: center());
  }

  Widget withDottedBorder({
    double strokeWidth = 1,
    Color? color,
    double radius = 16,
    EdgeInsets? padding,
  }) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(radius),
      padding: padding ?? EdgeInsets.zero,
      strokeWidth: strokeWidth,
      dashPattern: const [6, 6],
      color: color ?? Styles.PRIMARY_COLOR,
      child: this,
    );
  }
}

extension PaddingExtension on Widget {
  /// return padding top
  Padding paddingTop(double top) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: this,
    );
  }

  /// return padding left
  Padding paddingLeft(double left) {
    return Padding(
      padding: EdgeInsets.only(left: left),
      child: this,
    );
  }

  /// return padding Directional
  Padding paddingStart(double start) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: start),
      child: this,
    );
  }

  Padding paddingEnd(double end) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: end),
      child: this,
    );
  }

  /// return padding right
  Padding paddingRight(double right) {
    return Padding(
      padding: EdgeInsets.only(right: right),
      child: this,
    );
  }

  /// return padding bottom
  Padding paddingBottom(double bottom) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: this,
    );
  }

  /// return padding all
  Padding paddingAll(double padding) {
    return Padding(padding: EdgeInsets.all(padding), child: this);
  }

  /// return padding Symmetric
  Padding paddingSymmetric(double horizontal, double vertical) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  Padding paddingVertical(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: this,
    );
  }

  Padding paddingHorizontal(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: this,
    );
  }

  /// return custom padding from each side
  Padding paddingOnly({double top = 0.0, double left = 0.0, double bottom = 0.0, double right = 0.0}) {
    return Padding(padding: EdgeInsets.fromLTRB(left, top, right, bottom), child: this);
  }

  Padding paddingDirectionalOnly({double top = 0.0, double start = 0.0, double bottom = 0.0, double end = 0.0}) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: top, bottom: bottom, start: start, end: end),
      child: this,
    );
  }

  Padding paddingDirectionalAll({double padding = 0}) {
    return Padding(padding: EdgeInsetsDirectional.all(padding), child: this);
  }
}

/// Extension on Widget to provide additional functionality related to routing.
extension RouterExtension on Widget {
  /// Builds a page with optional transition and duration.
  ///
  /// - The [transition] parameter specifies the page transition animation to be used.
  /// - The [duration] parameter specifies the duration of the transition animation.
  ///
  /// Returns a [Page] object representing the built page.
  Page<dynamic> buildPage({String? transition, Duration? duration}) {
    if (transition != null && transition == 'cupertino') {
      return CupertinoPage<dynamic>(child: this);
    } else {
      return MaterialPage<dynamic>(child: this);
    }
  }

  Widget withBlocProvider<T extends Cubit<Object>>(T bloc) => BlocProvider<T>.value(value: bloc, child: this);
}

/// Extension on the [Widget] class to provide additional layout-related functionality.
extension LayoutExtensions on Widget {
  /// With custom width
  SizedBox withWidth(double width) => SizedBox(width: width, child: this);

  /// With custom height
  SizedBox withHeight(double height) => SizedBox(height: height, child: this);

  /// With custom height and width
  SizedBox withSize(double width, double height) => SizedBox(width: width, height: height, child: this);

  ///scrollable
  Widget scrollable({EdgeInsets? padding, bool primary = true, bool reverse = false, ScrollPhysics? physics}) {
    return SingleChildScrollView(
      primary: primary,
      padding: padding ?? EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT, vertical: 16),
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      reverse: reverse,
      child: this,
    );
  }

  Widget withListView({
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    bool primary = true,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
  }) {
    return ListView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      primary: primary,
      shrinkWrap: shrinkWrap,
      padding: padding ?? EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT).copyWith(bottom: kBottomNavigationBarHeight),
      physics: physics,
      children: [this],
    );
  }

  /// add Expanded to parent widget
  Widget expand({int flex = 1, bool enabled = true}) {
    return enabled ? Expanded(flex: flex, child: this) : this;
  }

  /// add Flexible to parent widget
  Widget flexible({int flex = 1, FlexFit? fit, bool enabled = true}) {
    return enabled ? Flexible(flex: flex, fit: fit ?? FlexFit.loose, child: this) : this;
  }

  /// add FittedBox to parent widget
  Widget fit({BoxFit? fit, AlignmentGeometry? alignment}) {
    return FittedBox(fit: fit ?? BoxFit.contain, alignment: alignment ?? Alignment.center, child: this);
  }

  SliverToBoxAdapter toSliver() => SliverToBoxAdapter(child: this);

  Directionality withDirectionality(String dir) {
    final textDir = dir == 'ar' || dir == 'ur' ? material.TextDirection.rtl : material.TextDirection.ltr;
    return Directionality(textDirection: textDir, child: this);
  }
}

extension TransformExtension on Widget {
  /// add rotation to parent widget
  Widget rotate({required double angle, bool transformHitTests = true, Offset? origin}) {
    return Transform.rotate(origin: origin, angle: (angle * 3.141592653589793) / 180, transformHitTests: transformHitTests, child: this);
  }

  Widget flipHorizontal({bool enable = true, bool transformHitTests = true}) {
    return Transform.flip(flipX: enable, transformHitTests: transformHitTests, child: this);
  }

  Widget flipVertical({bool enable = true, bool transformHitTests = true}) {
    return Transform.flip(flipY: enable, transformHitTests: transformHitTests, child: this);
  }

  //rotate with animation to parent widget
  Widget rotateWithAnimation({required double angle}) {
    return RotationTransition(
      turns: AlwaysStoppedAnimation(angle / 360),
      filterQuality: FilterQuality.high,
      child: this,
    );
  }

  /// add scaling to parent widget
  Widget scale({required double scale, Offset? origin, AlignmentGeometry? alignment, bool transformHitTests = true}) {
    return Transform.scale(
      scale: scale,
      origin: origin,
      alignment: alignment,
      transformHitTests: transformHitTests,
      child: this,
    );
  }

  /// add translate to parent widget
  Widget translate({required Offset offset, bool transformHitTests = true, Key? key}) {
    return Transform.translate(offset: offset, transformHitTests: transformHitTests, key: key, child: this);
  }
}

extension AnimationExtension on Widget {
  Widget setHero(String heroKey) => Hero(
    tag: heroKey,
    child: Material(color: Colors.transparent, child: this),
  );

  /// add opacity to parent widget
  Widget opacity({required double opacity, int durationInSecond = 1, Duration? duration}) {
    return AnimatedOpacity(opacity: opacity, duration: duration ?? const Duration(milliseconds: 500), child: this);
  }

  /// Validate given widget is not null and returns given value if null.
  Widget animationSwitch({Duration? duration, Curve curve = Curves.easeInOut}) {
    return AnimatedSwitcher(
      duration: duration ?? transitionDuration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: this,
    );
  }

  Widget setAnimatedContainer({Duration? duration, double? width, double? hight}) {
    return AnimatedContainer(
      width: width,
      height: hight,
      curve: Curves.fastOutSlowIn,
      duration: duration ?? const Duration(seconds: 5),
      child: this,
    );
  }

  Widget setOpacityTween({bool isVisible = false, Duration? duration}) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 1.0, end: isVisible ? 1.0 : 0.0),
      duration: duration ?? const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Opacity(opacity: value, child: this);
      },
    );
  }
}

extension TextEx on Text {
  /// add tap to text widget
  Widget clickable({
    required void Function() onTap,
    Color splashColor = Colors.transparent,
    Color highlightColor = Colors.transparent,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    double paddingValue = 0.0,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    TextStyle? style,
  }) {
    final ValueNotifier<bool> highlighted = ValueNotifier<bool>(false);
    return ValueListenableBuilder(
      valueListenable: highlighted,
      builder: (context, value, child) {
        return InkWell(
          onTap: onTap,
          onHighlightChanged: (value) => highlighted.value = value,
          splashColor: value ? splashColor.withValues(alpha: 0.5) : splashColor,
          highlightColor: value ? highlightColor.withValues(alpha: 0.5) : highlightColor,
          borderRadius: borderRadius,
          onTapDown: (details) => highlighted.value = true,
          onTapUp: (details) => highlighted.value = false,
          onTapCancel: () => highlighted.value = false,
          child: AnimatedDefaultTextStyle(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 100),
            style:
                style?.copyWith(color: value ? style.color?.withValues(alpha: 0.5) : style.color) ??
                AppTextStyles.w600.copyWith(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: value ? Styles.PRIMARY_COLOR.withValues(alpha: 0.5) : Styles.PRIMARY_COLOR,
                ),
            child: Padding(padding: padding ?? EdgeInsets.all(paddingValue), child: this),
          ),
        );
      },
    );
  }
}

extension ColorEx on Color {
  ColorFilter get colorFilter => ColorFilter.mode(this, BlendMode.srcIn);

  Color darken([double amount = 0.1]) {
    final hslColor = HSLColor.fromColor(this);
    final darkenedHslColor = hslColor.withLightness((hslColor.lightness - amount).clamp(0.0, 1.0));
    return darkenedHslColor.toColor();
  }

  Color lighten([double amount = 0.1]) {
    final hslColor = HSLColor.fromColor(this);
    final lightenedHslColor = hslColor.withLightness((hslColor.lightness + amount).clamp(0.0, 1.0));
    return lightenedHslColor.toColor();
  }

  // darken color or lighten color based on the brightness
  Color adjustBrightness({double amount = .1}) {
    return computeLuminance() > 0.5 ? darken(amount) : lighten(amount);
  }
}

extension BoolExt on bool {
  T? toggle<T>(T? ifTrue, T? ifFalse) => this ? ifTrue : ifFalse;

  void toggleAction(void Function() ifTrue, void Function() ifFalse) {
    if (this) {
      ifTrue();
    } else {
      ifFalse();
    }
  }
}