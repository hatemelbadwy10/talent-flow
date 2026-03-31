import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions; // ⬅️ هنا ضفتها
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  const CustomAppBar({
    this.bottom,
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return AppBar(
      bottom: bottom,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      isRtl ? Icons.arrow_forward : Icons.arrow_back,
                      color: Colors.grey.shade700,
                    ),
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            )
          : null,
      leadingWidth: showBackButton ? 56 : null,
      titleSpacing: showBackButton ? 8 : 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            Images.appLogo,
            height: 28,
            width: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),

      // Keep any custom page actions; otherwise reserve nothing.
      actions: actions ?? const [],
    );
  }
}
