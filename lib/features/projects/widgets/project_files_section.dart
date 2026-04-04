import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/core/app_core.dart';
import '../../../app/core/app_notification.dart';
import '../../../app/core/dimensions.dart';
import '../../../app/core/styles.dart';
import '../../../components/image_pop_up_viewer.dart';

class ProjectFilesSection extends StatelessWidget {
  const ProjectFilesSection({
    super.key,
    required this.files,
  });

  final List<dynamic> files;

  @override
  Widget build(BuildContext context) {
    final attachments = _ProjectAttachment.fromList(files);
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final images = attachments.where((file) => file.isImage).toList();
    final documents = attachments.where((file) => !file.isImage).toList();

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Styles.BORDER_COLOR),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'project_files'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Styles.HEADER,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Styles.PRIMARY_COLOR.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  attachments.length.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Styles.PRIMARY_COLOR,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'project_files_hint'.tr(),
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Styles.HINT_COLOR,
            ),
          ),
          if (images.isNotEmpty) ...[
            SizedBox(height: 18.h),
            Text(
              'project_images'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Styles.HEADER,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 164.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final attachment = images[index];
                  return _ImageAttachmentCard(
                    attachment: attachment,
                    onTap: () => _showImagePreview(context, attachment),
                  );
                },
              ),
            ),
          ],
          if (documents.isNotEmpty) ...[
            SizedBox(height: images.isNotEmpty ? 20.h : 18.h),
            Text(
              'project_documents'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Styles.HEADER,
              ),
            ),
            SizedBox(height: 12.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: documents.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final attachment = documents[index];
                return _DocumentAttachmentTile(
                  attachment: attachment,
                  onTap: () => _openFile(context, attachment.url),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openFile(BuildContext context, String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) {
        _showLaunchError();
        return;
      }

      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!didLaunch) {
        _showLaunchError();
      }
    } catch (_) {
      _showLaunchError();
    }
  }

  void _showImagePreview(BuildContext context, _ProjectAttachment attachment) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => ImagePopUpViewer(
        image: attachment.url,
        title: attachment.name,
        isFromInternet: true,
      ),
    );
  }

  void _showLaunchError() {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: 'project_file_open_failed'.tr(),
        backgroundColor: Colors.red.shade50,
        borderColor: Colors.red.shade200,
      ),
    );
  }
}

class _ImageAttachmentCard extends StatelessWidget {
  const _ImageAttachmentCard({
    required this.attachment,
    required this.onTap,
  });

  final _ProjectAttachment attachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        width: 156.w,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  attachment.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5F8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 32,
                          color: Styles.HINT_COLOR,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.02),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 12.h,
              end: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: Styles.PRIMARY_COLOR,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'project_file_preview'.tr(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Styles.PRIMARY_COLOR,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              start: 12.w,
              end: 12.w,
              bottom: 12.h,
              child: Text(
                attachment.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentAttachmentTile extends StatelessWidget {
  const _DocumentAttachmentTile({
    required this.attachment,
    required this.onTap,
  });

  final _ProjectAttachment attachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EDF3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Styles.PRIMARY_COLOR.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  attachment.badgeLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Styles.PRIMARY_COLOR,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Styles.HEADER,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'project_file_open_hint'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Styles.HINT_COLOR,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD7DEE7)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 14,
                    color: Styles.PRIMARY_COLOR,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'project_file_open'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Styles.PRIMARY_COLOR,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectAttachment {
  const _ProjectAttachment({
    required this.url,
    required this.name,
    required this.extension,
    required this.isImage,
  });

  final String url;
  final String name;
  final String extension;
  final bool isImage;

  String get badgeLabel {
    if (extension.isEmpty) {
      return 'FILE';
    }

    final upper = extension.toUpperCase();
    return upper.length <= 4 ? upper : upper.substring(0, 4);
  }

  static List<_ProjectAttachment> fromList(List<dynamic> values) {
    return values.map(_fromDynamic).whereType<_ProjectAttachment>().toList();
  }

  static _ProjectAttachment? _fromDynamic(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return _fromUrl(url: value);
    }

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final url = _pickFirstNonEmpty([
        map['file'],
        map['url'],
        map['path'],
        map['attachment'],
      ]);

      if (url == null) {
        return null;
      }

      final fileName = _pickFirstNonEmpty([
        map['name'],
        map['title'],
        map['file_name'],
      ]);

      return _fromUrl(url: url, fileName: fileName);
    }

    return _fromUrl(url: value.toString());
  }

  static _ProjectAttachment? _fromUrl({
    required String url,
    String? fileName,
  }) {
    final normalizedUrl = url.trim();
    if (normalizedUrl.isEmpty) {
      return null;
    }

    final resolvedName = (fileName ?? _extractFileName(normalizedUrl)).trim();
    final extension = _extractExtension(resolvedName);

    return _ProjectAttachment(
      url: normalizedUrl,
      name: resolvedName,
      extension: extension,
      isImage: _imageExtensions.contains(extension.toLowerCase()),
    );
  }

  static String? _pickFirstNonEmpty(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate == null) {
        continue;
      }

      final value = candidate.toString().trim();
      if (value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  static String _extractFileName(String url) {
    final uri = Uri.tryParse(url);
    final path = uri?.path ?? url;
    final segment = path.split('/').where((part) => part.isNotEmpty).lastOrNull;
    if (segment == null || segment.isEmpty) {
      return 'attachment';
    }

    return Uri.decodeComponent(segment);
  }

  static String _extractExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }

    return fileName.substring(dotIndex + 1);
  }

  static const Set<String> _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
  };
}
