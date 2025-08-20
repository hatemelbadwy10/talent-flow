// file: custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/core/text_styles.dart';
import '../app/core/styles.dart';
import '../app/core/svg_images.dart';
import 'custom_error_widget.dart';
import 'custom_images.dart';

class CustomTextField extends StatefulWidget {
  // --- All your existing properties are preserved for app-wide flexibility ---
  final TextInputAction keyboardAction;
  final Color? iconColor;
  final TextInputType? inputType;
  final String? hint;
  final String? label;
  final void Function(String)? onChanged;
  final bool isPassword;
  final FocusNode? focusNode, nextFocus;
  final FormFieldValidator<String>? validate;
  final int? maxLines;
  final int? minLines;
  final TextEditingController? controller;
  final bool keyboardPadding;
  final bool withLabel;
  final bool readOnly;
  final int? maxLength;
  final bool obscureText;
  final bool? autoFocus;
  final bool? alignLabel;
  final dynamic errorText;
  final String? initialValue;
  final bool isEnabled;
  final bool? alignLabelWithHint;
  final bool? withPadding;
  final bool? customError;
  final GestureTapCallback? onTap;
  final Color? onlyBorderColor;
  final List<TextInputFormatter>? formattedType;
  final Alignment? align;
  final Function(dynamic)? onTapOutside;
  final double? height;
  final Iterable<String>? autofillHints;
  final String? sufSvgIcon, sufAssetIcon;
  final String? pAssetIcon, pSvgIcon;
  final Color? pIconColor, sIconColor;
  final Widget? prefixWidget, sufWidget;
  final void Function(String)? onSubmit;
  final TextDirection? textDirection;
  final double? width;

  const CustomTextField({
    super.key,
    this.height,
    this.sufAssetIcon,
    this.pAssetIcon,
    this.pSvgIcon,
    this.pIconColor,
    this.sIconColor,
    this.sufWidget,
    this.prefixWidget,
    this.sufSvgIcon,
    this.keyboardAction = TextInputAction.next,
    this.align,
    this.inputType,
    this.hint,
    this.alignLabelWithHint,
    this.onChanged,
    this.autofillHints,
    this.validate,
    this.obscureText = false,
    this.isPassword = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.isEnabled = true,
    this.withPadding = true,
    this.alignLabel = false,
    this.controller,
    this.errorText = "",
    this.maxLength,
    this.formattedType,
    this.focusNode,
    this.nextFocus,
    this.iconColor,
    this.keyboardPadding = false,
    this.autoFocus,
    this.initialValue,
    this.onlyBorderColor,
    this.customError = false,
    this.withLabel = false,
    this.label,
    this.onTap,
    this.onTapOutside,
    this.onSubmit,
    this.textDirection,
    this.width
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late String? error;
  bool _isHidden = true;
  bool _isFocus = false;

  @override
  void initState() {
    super.initState();
    error = null;
    widget.focusNode?.addListener(_onFocus);
  }

  void _onFocus() {
    if (mounted) {
      setState(() {
        _isFocus = widget.focusNode?.hasFocus ?? false;
      });
    }
  }

  void _visibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  // This function determines the color of the border
  Color activationBorderColor() {
    if (error != null) return Styles.ERORR_COLOR; // Error color takes precedence
    if (_isFocus) return Styles.PRIMARY_COLOR; // Color when the field is focused
    // **CHANGE**: Return a transparent color to hide the border when not focused
    return Styles.BORDER_COLOR;   }

  @override
  Widget build(BuildContext context) {
    // Using Directionality to ensure proper RTL layout for Arabic
    return Directionality(
      textDirection: widget.textDirection ?? TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.label != null) ...[
              RichText(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.label ?? "",
                      style: AppTextStyles.w600.copyWith(
                        fontSize: 14,
                        color: Styles.HEADER,
                      ),
                    ),
                    if (widget.validate != null)
                      const WidgetSpan(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            " *",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Styles.ERORR_COLOR,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
            ],

            // This container creates the background and border
            Container(
              width: widget.width ?? context.width,
              decoration: BoxDecoration(
                // **CHANGE**: The background is now always white
                  color: Styles.WHITE_COLOR,
                  border: Border.all(
                    color: activationBorderColor(), // Uses our updated color logic
                  ),
                  borderRadius: BorderRadius.circular(12.w)),
              child: TextFormField(
                // --- All your existing logic is preserved ---
                autofillHints: widget.autofillHints,
                focusNode: widget.focusNode,
                onFieldSubmitted: (v) {
                  widget.onSubmit?.call(v);
                  setState(() => _isFocus = false);
                  if (widget.nextFocus != null) {
                    FocusScope.of(context).requestFocus(widget.nextFocus);
                  } else {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                initialValue: widget.initialValue,
                textInputAction: widget.keyboardAction,
                onTap: widget.onTap,
                onTapOutside: (v) {
                  widget.onTapOutside?.call(v);
                  setState(() => _isFocus = false);
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                autofocus: widget.autoFocus ?? false,
                maxLength: widget.maxLength,
                readOnly: widget.readOnly,
                obscureText: widget.isPassword ? _isHidden : widget.obscureText,
                obscuringCharacter: "*",
                controller: widget.controller,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                validator: (v) {
                  setState(() => error = widget.validate?.call(v));
                  return widget.validate?.call(v);
                },
                keyboardType: widget.inputType,
                onChanged: widget.onChanged,
                inputFormatters: widget.formattedType,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  overflow: TextOverflow.ellipsis,
                  color: Styles.HEADER,
                ),
                scrollPadding:
                EdgeInsets.only(bottom: context.bottom),

                // **CHANGE**: Align hint and input text to the right for Arabic
                textAlign: TextAlign.right,

                // --- Decoration for the text field itself ---
                decoration: InputDecoration(
                  // These borders must be none so the container's border is visible
                  disabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  errorStyle: const TextStyle(height: 0, fontSize: 0),

                  // Hint text styling
                  hintText: widget.hint,
                  hintStyle: AppTextStyles.w600.copyWith(
                    color: Styles.HINT_COLOR,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),

                  // Your password toggle icon logic is preserved perfectly
                  suffixIcon: widget.isPassword
                      ? IconButton(
                    onPressed: _visibility,
                    icon: _isHidden
                        ? customImageIconSVG(imageName: SvgImages.hiddenEyeIcon)
                        : customImageIconSVG(imageName: SvgImages.eyeIcon, color: Styles.PRIMARY_COLOR),
                  )
                      : null,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                ),
              ),
            ),
            if (error != null) CustomErrorWidget(error: error),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocus);
    super.dispose();
  }
}