import 'package:flutter/material.dart';
class HelperText extends StatelessWidget {
  const HelperText({super.key, required this.text});
final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(text,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)));
  }
}
