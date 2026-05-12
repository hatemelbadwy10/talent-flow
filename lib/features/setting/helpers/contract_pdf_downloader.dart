import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
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
    final page = document.pages.add();
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

    double top = 20;
    final width = page.getClientSize().width - 40;

    top = _drawTextBlock(
      page: page,
      text: contract.title?.trim().isNotEmpty == true
          ? contract.title!
          : 'عقد عمل',
      font: boldFont,
      bounds: Rect.fromLTWH(20, top, width, 40),
      format: _rtlFormat(PdfTextAlignment.center),
    );

    top += 12;
    top = _drawInfoRow(page, 'رقم العقد', '#${contract.id ?? '-'}', baseFont, top);
    top = _drawInfoRow(page, 'عنوان المشروع', contract.projectTitle, baseFont, top);
    top = _drawInfoRow(page, 'صاحب المشروع', contract.projectOwner, baseFont, top);
    top = _drawInfoRow(page, 'المستقل', contract.freelancer, baseFont, top);
    top = _drawInfoRow(page, 'التاريخ', contract.date, baseFont, top);
    top = _drawInfoRow(page, 'الميزانية', contract.budget, baseFont, top);
    top = _drawInfoRow(page, 'المدة', contract.duration, baseFont, top);
    top = _drawInfoRow(page, 'نسبة Talent Flow', contract.talentPercentageOfContracts,
        baseFont, top);

    top += 14;
    top = _drawSection(page, 'وصف المشروع', contract.projectDescription, sectionFont,
        baseFont, top);
    top = _drawSection(page, 'الشروط', contract.terms, sectionFont, baseFont, top);
    top = _drawSection(page, 'الملاحظات', contract.notes, sectionFont, baseFont, top);
    top = _drawSection(
      page,
      'شروط الإنهاء',
      _stripHtml(contract.terminationConditions),
      sectionFont,
      baseFont,
      top,
    );
    top = _drawSection(
      page,
      'سياسة النزاعات',
      _stripHtml(contract.conflictPolicy),
      sectionFont,
      baseFont,
      top,
    );

    if (contract.files.isNotEmpty) {
      top = _drawSection(
        page,
        'المرفقات',
        contract.files.map(_fileNameFromUrl).join('\n'),
        sectionFont,
        baseFont,
        top,
      );
    }

    final bytes = document.saveSync();
    document.dispose();
    return bytes;
  }

  static double _drawInfoRow(
    PdfPage page,
    String label,
    String? value,
    PdfFont font,
    double top,
  ) {
    return _drawTextBlock(
          page: page,
          text: '$label: ${value?.trim().isNotEmpty == true ? value! : '-'}',
          font: font,
          bounds: Rect.fromLTWH(20, top, page.getClientSize().width - 40, 40),
          format: _rtlFormat(PdfTextAlignment.right),
        ) +
        8;
  }

  static double _drawSection(
    PdfPage page,
    String title,
    String? value,
    PdfFont titleFont,
    PdfFont bodyFont,
    double top,
  ) {
    final resolvedValue = value?.trim().isNotEmpty == true ? value! : '-';
    top = _drawTextBlock(
          page: page,
          text: title,
          font: titleFont,
          bounds: Rect.fromLTWH(20, top, page.getClientSize().width - 40, 30),
          format: _rtlFormat(PdfTextAlignment.right),
        ) +
        6;
    top = _drawTextBlock(
          page: page,
          text: resolvedValue,
          font: bodyFont,
          bounds: Rect.fromLTWH(20, top, page.getClientSize().width - 40, 200),
          format: _rtlFormat(PdfTextAlignment.right),
        ) +
        14;
    return top;
  }

  static double _drawTextBlock({
    required PdfPage page,
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
    final result = element.draw(page: page, bounds: bounds);
    return result?.bounds.bottom ?? bounds.bottom;
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
