import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsMenuItem extends StatelessWidget {
  const SettingsMenuItem({
    super.key,
    this.onTap,
    this.icon,
    this.svgIconPath,
    required this.text,
    this.secondaryText,
    this.textColor,
    this.iconColor,
  });

  final void Function()? onTap;
  final IconData? icon;
  final String? svgIconPath;
  final String text;
  final String? secondaryText;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            if (svgIconPath != null)
              SvgPicture.asset(
                svgIconPath!,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  iconColor ?? Colors.grey.shade600,
                  BlendMode.srcIn,
                ),
              )
            else
              Icon(icon, color: iconColor ?? Colors.grey.shade600),
            const SizedBox(width: 16.0),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.black87,
              ),
            ),
            const Spacer(),
            if (secondaryText != null)
              Text(
                secondaryText!,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
