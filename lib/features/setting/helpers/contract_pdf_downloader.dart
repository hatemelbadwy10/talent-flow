import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;

import '../../../app/core/app_core.dart';
import '../../../app/core/app_notification.dart';
import '../../../app/core/styles.dart';
import '../../../helpers/permissions.dart';

class ContractPdfDownloader {
  static const String _assetPath = 'assets/contracts/delivery_app_contract.pdf';

  static Future<void> downloadTemplate() async {
    final hasPermission = await PermissionHandler.checkFilePermission();
    if (!hasPermission) {
      _showError('contracts_screen.download_permission_denied'.tr());
      return;
    }

    try {
      final assetData = await rootBundle.load(_assetPath);
      final directoryPath = await AppCore.getAppFilePath();
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File(
        path.join(directory.path, 'talent_flow_contract.pdf'),
      );

      await file.writeAsBytes(
        assetData.buffer.asUint8List(),
        flush: true,
      );

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
