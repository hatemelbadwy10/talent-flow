import 'dart:io';
import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

abstract class PermissionHandler {
  static Future<bool> _requestPermission(
    Permission permission, {
    bool openSettingsOnPermanentDenial = true,
  }) async {
    var status = await permission.status;
    log('Permission ${permission.toString()} initial status: ${status.name}');

    if (status.isGranted) {
      return true;
    }

    status = await permission.request();
    log('Permission ${permission.toString()} request status: ${status.name}');

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied && openSettingsOnPermanentDenial) {
      await openAppSettings();
    }

    return false;
  }

  static Future<bool> checkCameraPermission() async =>
      _requestPermission(Permission.camera);
  static Future<bool> checkBluetoothPermission() async =>
      _requestPermission(Permission.bluetoothConnect);
  static Future<bool> checkContactsPermission() async =>
      _requestPermission(Permission.contacts);
  static Future<bool> checkGalleryPermission() async =>
      _requestPermission(Permission.photos);
  static Future<bool> checkNotificationsPermission() async =>
      _requestPermission(Permission.notification);
  static Future<bool> checkStoragePermission() async =>
      _requestPermission(Permission.storage);

  static Future<bool> checkFilePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final storageGranted = await _requestPermission(
      Permission.storage,
      openSettingsOnPermanentDenial: false,
    );
    if (storageGranted) {
      return true;
    }

    return _requestPermission(Permission.manageExternalStorage);
  }

  static Future<bool> checkMicrophonePermission() async =>
      _requestPermission(Permission.microphone);
}
