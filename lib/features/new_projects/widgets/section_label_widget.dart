import 'package:flutter/material.dart';
class SectionLabel extends StatelessWidget {
  const SectionLabel( {super.key,required this.text,   this.isRequired =false, this.trailing});
final String text;
final bool isRequired;
final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
              text: TextSpan(
                  text: text,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                  children: <TextSpan>[
                    if (isRequired)
                      const TextSpan(
                          text: ' *',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold))
                  ])),
          if (trailing != null) trailing??SizedBox()
        ]);
  }
}
