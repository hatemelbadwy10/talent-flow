import 'package:flutter/material.dart';

class FavouriteToggleButton extends StatelessWidget {
  const FavouriteToggleButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFFFFEEF0) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          Icons.favorite,
          size: 18,
          color: isEnabled ? const Color(0xFFDB5353) : const Color(0xFFB6BAC1),
        ),
      ),
    );
  }
}
