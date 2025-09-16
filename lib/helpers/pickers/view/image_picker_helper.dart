import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/localization/language_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/error/api_error_handler.dart';
import '../../../navigation/custom_navigation.dart';
import 'package:image/image.dart' as img;

abstract class ImagePickerHelper {
  static showOptionDialog({ValueChanged<File>? onGet}) {
    showDialog(
      context: CustomNavigator.navigatorState.currentContext!,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(
            getTranslated("choose_your_image"),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            CupertinoDialogAction(
                child: Text(getTranslated("gallery")),
                onPressed: () => openGallery(onGet: onGet, fromOptions: true)),
            CupertinoDialogAction(
                child: Text(getTranslated("camera")),
                onPressed: () => openCamera(onGet: onGet, fromOptions: true)),
          ],
        );
      },
    );
  }

  static Future<File> compressImage(File file) async {
    // Define maximum height and width for compressed image
    // Get the path of the original image file
    String filePath = file.path;

    // Compress the image
    Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
      filePath,
      minHeight: 1920,
      minWidth: 1080,
      quality: 10,
    );
    return await convertJpgToPng(compressedBytes!);
  }

  static Future<File> convertJpgToPng(Uint8List inputPath) async {
    // Decode the JPEG image
    img.Image? image = img.decodeImage(inputPath);

    // Encode the image to PNG
    List<int> pngBytes = img.encodePng(image!);

    // Create a temporary file to store the PNG image
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/${DateTime.now().microsecond}.png');

    // Write the PNG bytes to the temporary file
    await tempFile.writeAsBytes(pngBytes);

    // Return the temporary file
    return tempFile;
  }

  static showOptionSheet({ValueChanged<File>? onGet}) {
    showCupertinoModalPopup(
        context: CustomNavigator.navigatorState.currentContext!,
        builder: (_) {
          return CupertinoActionSheet(
            title: Text(
              "choose_your_image",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                  child: Text("gallery"),
                  onPressed: () =>
                      openGallery(onGet: onGet, fromOptions: true)),
              CupertinoDialogAction(
                  child: Text("camera"),
                  onPressed: () => openCamera(onGet: onGet, fromOptions: true)),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => CustomNavigator.pop(),
              child: Text(("cancel"),
                  style: const TextStyle(color: Colors.red)),
            ),
          );
        });
  }

  static openGallery(
      {ValueChanged<File>? onGet, bool fromOptions = false}) async {
    try {
      if (fromOptions == true) {
        CustomNavigator.pop();
      }
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        var pngImage = await compressImage(File(image.path));
        onGet?.call(File(pngImage.path));
      }
    } catch (e) {
      log("e from images $e");
      AppCore.showToast(e.toString());
    }
  }

  static openCamera({ValueChanged<File>? onGet, bool? fromOptions}) async {
    try {
      if (fromOptions == true) {
        CustomNavigator.pop();
      }
      var image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        var pngImage = await compressImage(File(image.path));
        onGet?.call(File(pngImage.path));
      }
    } catch (e) {
      AppCore.showToast(ApiErrorHandler.getServerFailure(e));
    }
  }

  static getMultiImages(ValueChanged<List<File>>? onGet) async {
    try {
      var images = await ImagePicker().pickMultiImage();
      List<File> pngImages = [];
      for (var image in images) {
        var v = await compressImage(File(image.path));
        pngImages.add(v);
      }
      onGet?.call(pngImages);
    } catch (e) {
      AppCore.showToast(ApiErrorHandler.getServerFailure(e));
    }
  }
}
