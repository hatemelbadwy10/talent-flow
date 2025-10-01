import 'package:flutter/material.dart';
import '../../../app/core/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? logo;
  final List<Widget>? actions; // ⬅️ هنا ضفتها
  final PreferredSizeWidget? bottom;
  const CustomAppBar({
    this.bottom,
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.logo,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      bottom: bottom
      ,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,

      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      )
          : null,

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo ??
              Image.asset(
                Images.appLogo,
                height: 30,
                fit: BoxFit.contain,
              ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),

      // ✅ هنا استخدمنا actions لو مش null، لو null حطينا SizedBox
      actions: actions ?? [const SizedBox.shrink()],

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff0C7D81),
              Color(0xff0AA1A6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
