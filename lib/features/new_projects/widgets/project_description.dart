import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // <-- 1. Import the package
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/features/projects/model/single_project_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/core/styles.dart';

class ProjectDescription extends StatelessWidget {
  const ProjectDescription({super.key, this.singleProjectModel});
  final SingleProjectModel? singleProjectModel;

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = singleProjectModel;

    if (project == null) {
      return const SizedBox.shrink(); // لو مفيش داتا
    }

    return Container(
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
          // 🔹 الوصف (description)
          if (project.description != null && project.description!.isNotEmpty)
            Text(
              project.description!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),

          if (project.description != null && project.description!.isNotEmpty)
            const SizedBox(height: 16.0),

          if (project.description != null && project.description!.isNotEmpty)
            const Divider(),

          // 🔹 filesDescription + لينك
          if (project.filesDescription != null &&
              project.filesDescription.toString().isNotEmpty)
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.7,
                ),
                children: <TextSpan>[
                  TextSpan(text: project.filesDescription.toString()),
                  TextSpan(
                    text: 'project_description.link_text'.tr(),
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchURL('https://portal.salla.part');
                      },
                  ),
                  TextSpan(text: 'project_description.paragraph_part2'.tr()),
                ],
              ),
            ),

          if (project.filesDescription != null &&
              project.filesDescription.toString().isNotEmpty)
            const SizedBox(height: 24.0),

          // 🔹 المرفقات (files)
          if (project.files.isNotEmpty)
            ...project.files.map((fileUrl) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fileUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              );
            }).toList(),

        ],
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
          decoration: const BoxDecoration(color: Styles.PRIMARY_COLOR),
          child: Center(
            child: Text(
              fileName.split('.').last.toUpperCase(), // 👈 الامتداد (JPEG, PDF...)
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          fileName,
          style: const TextStyle(
            color: Styles.PRIMARY_COLOR,
            fontSize: 14,
          ),
        ),
        if (fileSize.isNotEmpty) const SizedBox(width: 4.0),
        if (fileSize.isNotEmpty)
          Text(
            '($fileSize)',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
      ],
    );
  }
}
