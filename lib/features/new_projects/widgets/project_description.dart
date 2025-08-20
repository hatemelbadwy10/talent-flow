import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/core/styles.dart';



class ProjectDescription extends StatelessWidget {
  const ProjectDescription({super.key});


  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // You can show a snackbar or toast here in case of failure
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade200),

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Title
            const Text(
              "تفاصيل المشروع",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 16.0),
            const Divider(),

            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.7, // Line height for better readability
                  fontFamily: 'IBMPlexSansArabic', // Ensure you have this font
                ),
                children: <TextSpan>[
                  const TextSpan(
                      text:
                      'قبل إن ترسل عرض مهم، التيم يتم تنفيذه على منصة الشركاء تبع سله لهم نظام وهو إن تدخل على موقعهم هنا'),
                  TextSpan(
                    text: ' https://portal.salla.part...',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    // Recognizer to make the link tappable
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchURL('https://portal.salla.part');
                      },
                  ),
                  const TextSpan(
                    text:
                    ' ويتم انشاء ثيم وربط على GitHub وتنزيل ملف برمجي لثيم افتراضي وبناء الثيم المطلوب للعمل عليه اعتقد انه يكون بالتعديل.\n اللي ماعنده فكره يدخل يعمل حساب ويتاكد من الوضع قبل ارسال عرض تفاصيل الثيم المطلوبه.\n وايضا ارفقت صور لطريقة بعض الافكار.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Section 3: Attachments
            _buildAttachmentRow("IMG5342.jpeg", "500.4KB"),
            const SizedBox(height: 8.0),
            _buildAttachmentRow("IMG5342.jpeg", "500.4KB"),
            const SizedBox(height: 8.0),
            _buildAttachmentRow("IMG5342.jpeg", "500.4KB"),
          ],
        ),
      ),
    );
  }

  /// Helper widget to build a single row for an attachment.
  Widget _buildAttachmentRow(String fileName, String fileSize) {
    return Row(
      children: [
        Container(
          height: 43,
          width: 43,
          decoration: const BoxDecoration(
            color: Styles.PRIMARY_COLOR
          ),
          child: const Center(
            child: Text(
              'Jpeg',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500
              )
            ),
          ),
        ),
        SizedBox(width:8.w),

        Text(
          fileName,
          style: const TextStyle(
            color: Styles.PRIMARY_COLOR,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4.0),
        Text(
          '($fileSize)',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),

      ],
    );
  }
}