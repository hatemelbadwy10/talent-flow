import 'package:flutter/material.dart';

import '../../../app/core/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? logo; // تقدر تمرر لوجو خاص لو حبيت

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.logo,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,

      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      )
          : null,

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logo != null)
            logo!
          else
            Image.asset(
              Images.appLogo,
              height: 30,
              fit: BoxFit.contain,
            ),

          const SizedBox(width: 8),

          // النص بجانب اللوجو
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
