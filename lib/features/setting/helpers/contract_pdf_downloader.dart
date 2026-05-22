import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../app/core/app_core.dart';
import '../../../app/core/app_notification.dart';
import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import '../../../helpers/permissions.dart';
import '../model/contract_model.dart';
import '../repo/contracts_repo.dart';

class ContractPdfDownloader {
  static const String _fontPath =
      'assets/fonts/IBMPlexSansArabic-Regular.ttf';

  static Future<void> downloadContract(ContractModel contract) async {
    final hasPermission = await PermissionHandler.checkFilePermission();
    if (!hasPermission) {
      _showError('contracts_screen.download_permission_denied'.tr());
      return;
    }

    try {
      final resolvedContract = await _resolveContract(contract);
      final pdfBytes = await _buildPdf(resolvedContract);

      final directoryPath = await AppCore.getAppFilePath();
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final safeTitle = _sanitizeFileName(
        resolvedContract.title?.trim().isNotEmpty == true
            ? resolvedContract.title!
            : 'talent_flow_contract_${resolvedContract.id ?? ''}',
      );
      final file = File(
        path.join(directory.path, '$safeTitle.pdf'),
      );

      await file.writeAsBytes(pdfBytes, flush: true);

      final result = await OpenFilex.open(file.path);
      if (result.type == ResultType.error) {
        _showError('something_went_wrong'.tr());
        return;
      }

      _showSuccess('contracts_screen.download_success'.tr());
    } catch (_) {
      _showError('something_went_wrong'.tr());
    }
  }

  static Future<ContractModel> _resolveContract(ContractModel contract) async {
    final contractId = contract.id;
    if (contractId == null) {
      return contract;
    }

    final result = await sl<ContractsRepo>().getContractDetails(contractId);
    return result.fold(
      (_) => contract,
      (response) {
        final data = response.data;
        if (data is Map && data['payload'] is Map<String, dynamic>) {
          return ContractModel.fromJson(data['payload'] as Map<String, dynamic>);
        }
        if (data is Map && data['payload'] is Map) {
          return ContractModel.fromJson(
            Map<String, dynamic>.from(data['payload'] as Map),
          );
        }
        return contract;
      },
    );
  }

  static Future<List<int>> _buildPdf(ContractModel contract) async {
    final document = PdfDocument();
    final firstPage = document.pages.add();
    final fontData = await rootBundle.load(_fontPath);
    final baseFont = PdfTrueTypeFont(
      fontData.buffer.asUint8List(),
      14,
    );
    final boldFont = PdfTrueTypeFont(
      fontData.buffer.asUint8List(),
      20,
      style: PdfFontStyle.bold,
    );
    final sectionFont = PdfTrueTypeFont(
      fontData.buffer.asUint8List(),
      16,
      style: PdfFontStyle.bold,
    );

    var cursor = _PdfCursor(document: document, page: firstPage, top: 20);
    final width = firstPage.getClientSize().width - 40;

    cursor = _drawTextBlock(
      cursor: cursor,
      text: contract.title?.trim().isNotEmpty == true
          ? contract.title!
          : 'عقد عمل',
      font: boldFont,
      bounds: Rect.fromLTWH(20, cursor.top, width, 40),
      format: _rtlFormat(PdfTextAlignment.center),
    );

    cursor = cursor.copyWith(top: cursor.top + 12);
    cursor =
        _drawInfoRow(cursor, 'رقم العقد', '#${contract.id ?? '-'}', baseFont);
    cursor = _drawInfoRow(cursor, 'عنوان المشروع', contract.projectTitle, baseFont);
    cursor = _drawInfoRow(cursor, 'صاحب المشروع', contract.projectOwner, baseFont);
    cursor = _drawInfoRow(cursor, 'المستقل', contract.freelancer, baseFont);
    cursor = _drawInfoRow(cursor, 'التاريخ', contract.date, baseFont);
    cursor = _drawInfoRow(cursor, 'الميزانية', contract.budget, baseFont);
    cursor = _drawInfoRow(cursor, 'المدة', contract.duration, baseFont);
    cursor = _drawInfoRow(
      cursor,
      'نسبة Talent Flow',
      contract.talentPercentageOfContracts,
      baseFont,
    );

    cursor = cursor.copyWith(top: cursor.top + 14);
    cursor = _drawSection(
      cursor,
      'وصف المشروع',
      contract.projectDescription,
      sectionFont,
      baseFont,
    );
    cursor = _drawSection(
      cursor,
      'الشروط',
      contract.terms,
      sectionFont,
      baseFont,
    );
    cursor = _drawSection(
      cursor,
      'الملاحظات',
      contract.notes,
      sectionFont,
      baseFont,
    );
    cursor = _drawSection(
      cursor,
      'شروط الإنهاء',
      _stripHtml(contract.terminationConditions),
      sectionFont,
      baseFont,
    );
    cursor = _drawSection(
      cursor,
      'سياسة النزاعات',
      _stripHtml(contract.conflictPolicy),
      sectionFont,
      baseFont,
    );

    if (contract.files.isNotEmpty) {
      cursor = await _drawAttachmentsSection(
        cursor,
        contract.files,
        sectionFont,
        baseFont,
      );
    }

    final bytes = document.saveSync();
    document.dispose();
    return bytes;
  }

  static _PdfCursor _drawInfoRow(
    _PdfCursor cursor,
    String label,
    String? value,
    PdfFont font,
  ) {
    return _drawTextBlock(
          cursor: cursor,
          text: '$label: ${value?.trim().isNotEmpty == true ? value! : '-'}',
          font: font,
          bounds: Rect.fromLTWH(
            20,
            cursor.top,
            cursor.page.getClientSize().width - 40,
            40,
          ),
          format: _rtlFormat(PdfTextAlignment.right),
        )
        .copyWithSpacing(8);
  }

  static _PdfCursor _drawSection(
    _PdfCursor cursor,
    String title,
    String? value,
    PdfFont titleFont,
    PdfFont bodyFont,
  ) {
    final resolvedValue = value?.trim().isNotEmpty == true ? value! : '-';
    cursor = _drawTextBlock(
          cursor: cursor,
          text: title,
          font: titleFont,
          bounds: Rect.fromLTWH(
            20,
            cursor.top,
            cursor.page.getClientSize().width - 40,
            30,
          ),
          format: _rtlFormat(PdfTextAlignment.right),
        )
        .copyWithSpacing(6);
    cursor = _drawTextBlock(
          cursor: cursor,
          text: resolvedValue,
          font: bodyFont,
          bounds: Rect.fromLTWH(
            20,
            cursor.top,
            cursor.page.getClientSize().width - 40,
            cursor.page.getClientSize().height - cursor.top - 20,
          ),
          format: _rtlFormat(PdfTextAlignment.right),
        )
        .copyWithSpacing(14);
    return cursor;
  }

  static Future<_PdfCursor> _drawAttachmentsSection(
    _PdfCursor cursor,
    List<String> files,
    PdfFont titleFont,
    PdfFont bodyFont,
  ) async {
    cursor = _drawTextBlock(
          cursor: cursor,
          text: 'المرفقات',
          font: titleFont,
          bounds: Rect.fromLTWH(
            20,
            cursor.top,
            cursor.page.getClientSize().width - 40,
            30,
          ),
          format: _rtlFormat(PdfTextAlignment.right),
        )
        .copyWithSpacing(10);

    for (final file in files) {
      final fileName = _fileNameFromUrl(file);
      cursor = _drawTextBlock(
            cursor: cursor,
            text: fileName,
            font: bodyFont,
            bounds: Rect.fromLTWH(
              20,
              cursor.top,
              cursor.page.getClientSize().width - 40,
              30,
            ),
            format: _rtlFormat(PdfTextAlignment.right),
          )
          .copyWithSpacing(8);

      if (!_isImageUrl(file)) {
        continue;
      }

      final bytes = await _downloadAttachmentBytes(file);
      if (bytes == null || bytes.isEmpty) {
        continue;
      }

      try {
        final image = PdfBitmap(bytes);
        final contentWidth = cursor.page.getClientSize().width - 40;
        const maxImageHeight = 220.0;
        final widthScale = contentWidth / image.width;
        final heightScale = maxImageHeight / image.height;
        final scale = math.min(widthScale, heightScale);
        final imageWidth = image.width * scale;
        final imageHeight = image.height * scale;

        cursor = _ensureSpace(cursor, imageHeight + 12);
        cursor.page.graphics.drawImage(
          image,
          Rect.fromLTWH(
            20 + (contentWidth - imageWidth),
            cursor.top,
            imageWidth,
            imageHeight,
          ),
        );
        cursor = cursor.copyWithSpacing(imageHeight + 14);
      } catch (_) {
        // Keep the filename visible even if the image bytes cannot be decoded.
      }
    }

    return cursor;
  }

  static _PdfCursor _drawTextBlock({
    required _PdfCursor cursor,
    required String text,
    required PdfFont font,
    required Rect bounds,
    required PdfStringFormat format,
  }) {
    final element = PdfTextElement(
      text: text,
      font: font,
      format: format,
    );
    final result = element.draw(
      page: cursor.page,
      bounds: bounds,
      format: PdfLayoutFormat(
        layoutType: PdfLayoutType.paginate,
        breakType: PdfLayoutBreakType.fitPage,
        paginateBounds: Rect.fromLTWH(
          20,
          20,
          cursor.page.getClientSize().width - 40,
          cursor.page.getClientSize().height - 40,
        ),
      ),
    );
    final resolvedPage = result?.page ?? cursor.page;
    final resolvedTop = result?.bounds.bottom ?? bounds.bottom;
    return _PdfCursor(
      document: cursor.document,
      page: resolvedPage,
      top: resolvedTop,
    );
  }

  static _PdfCursor _ensureSpace(_PdfCursor cursor, double requiredHeight) {
    final remainingHeight =
        cursor.page.getClientSize().height - cursor.top - 20;
    if (remainingHeight >= requiredHeight) {
      return cursor;
    }

    final nextPage = cursor.document.pages.add();
    return _PdfCursor(document: cursor.document, page: nextPage, top: 20);
  }

  static PdfStringFormat _rtlFormat(PdfTextAlignment alignment) {
    return PdfStringFormat(
      alignment: alignment,
      textDirection: PdfTextDirection.rightToLeft,
      lineAlignment: PdfVerticalAlignment.top,
    );
  }

  static String _stripHtml(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    return value
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  static String _sanitizeFileName(String value) {
    return value.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  static String _fileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final segment = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : url.split('/').last;
    return Uri.decodeComponent(segment);
  }

  static bool _isImageUrl(String url) {
    final extension = path.extension(Uri.tryParse(url)?.path ?? url)
        .toLowerCase()
        .replaceFirst('.', '');
    return extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'png' ||
        extension == 'webp';
  }

  static Future<List<int>?> _downloadAttachmentBytes(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      return await consolidateHttpClientResponseBytes(response);
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  static void _showSuccess(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Styles.PRIMARY_COLOR,
        isFloating: true,
      ),
    );
  }

  static void _showError(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Colors.red.shade50,
        borderColor: Colors.red.shade200,
        isFloating: true,
      ),
    );
  }
}

class _PdfCursor {
  const _PdfCursor({
    required this.document,
    required this.page,
    required this.top,
  });

  final PdfDocument document;
  final PdfPage page;
  final double top;

  _PdfCursor copyWith({
    PdfDocument? document,
    PdfPage? page,
    double? top,
  }) {
    return _PdfCursor(
      document: document ?? this.document,
      page: page ?? this.page,
      top: top ?? this.top,
    );
  }

  _PdfCursor copyWithSpacing(double spacing) {
    return copyWith(top: top + spacing);
  }
}
