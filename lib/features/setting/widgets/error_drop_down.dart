import 'package:flutter/material.dart';
class ErrorDropDown extends StatelessWidget {
  const ErrorDropDown({super.key, required this.label, required this.errorText});
final String label,errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
              children: const [
                TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontSize: 16))
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.red.shade200, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(errorText, style: TextStyle(color: Colors.red.shade800))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

