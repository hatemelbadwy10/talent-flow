import 'package:flutter/material.dart';
import '../../../app/core/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions; // ⬅️ هنا ضفتها
  final PreferredSizeWidget? bottom;
  const CustomAppBar({
    this.bottom,
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      bottom: bottom,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,

      leading: Padding(
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
                    icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
                    onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
      leadingWidth: showBackButton ? 56 : null,

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            Images.appLogo,
            height: 30,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),

      // ✅ هنا استخدمنا actions لو مش null، لو null حطينا SizedBox
      actions: actions ?? [const SizedBox.shrink()],
    );
  }
}
