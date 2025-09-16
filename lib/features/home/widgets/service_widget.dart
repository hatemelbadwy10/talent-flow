import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ServiceWidget extends StatelessWidget {
  final String iconPath;
  final String label;

  const ServiceWidget({
    super.key,
    required this.iconPath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74, // Ensures equal width
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 74,
            width: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xffF7F7F7),
            ),
            child: Padding(
              padding: const EdgeInsets.all(21),
              child: Image.network(
                iconPath,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36, // Fixed height for the text area
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2, // Allow up to 2 lines
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
