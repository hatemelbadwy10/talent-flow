import 'dart:io';
import 'dart:math';
import 'dart:developer' as print;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:talent_flow/app/localization/language_constant.dart';

import '../../../app/core/app_core.dart';

abstract class FilePickerHelper {
  static Future pickFile({
    String title = "Pick a file",
    FileType? type,
    List<String>? allowedExtensions,
    ValueChanged<File>? onSelected,
    ValueChanged<List<File>>? onSelectedMulti,
    bool multiImages = false,
    Function()? onCancel,
  }) async {
    var result = await FilePicker.platform.pickFiles(
      type: type ?? FileType.any,
      allowMultiple: multiImages,
      dialogTitle: title,
    );
    if (result != null) {
      List<File> files = [];
      for (var element in result.files) {
        files.add(File(element.path!));
      }

      if (checkFileType(files.first, type ?? FileType.any)) {
        if (onSelected != null) {
          onSelected.call(files.first);
        }
        if (onSelectedMulti != null) onSelectedMulti(files);
      }
    } else {
      onCancel?.call();

      return null;
    }
  }

  static checkFileType(File file, FileType type) {
    print.log("========> Picked File ${file.path}");
    print.log("========> Actual File Type $type");
    if (getFileExtension(type).contains(file.path.split(".").last)) {
      return true;
    } else {
      AppCore.showToast(
        getTranslated("file_type_validation"),
      );
      return false;
    }
  }

  static List<String> getFileExtension(FileType type) {
    print.log("========> Actual File Type $type");
    if (type == FileType.video) {
      return ["3gp", "avi", "mp4", "MP4", "gif", "mov", "wmv", "hevc", "flv", "fyi"];
    } else if (type == FileType.audio) {
      return ["mpeg", "mpga", "mp3", "wav", "aac", "m4a", "ogg", "flac"];
    } else if (type == FileType.image) {
      return ["png", "jpg", "jpeg", "gif", "tiff", "tif"];
    } else {
      return ["pdf", "jpg", "png", "xlsx", "xls", "doc", "docx", "txt", "svga"];
    }
  }

  static getFileSize(File file, int decimals) async {
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return (bytes / pow(1024, i)).toStringAsFixed(decimals) + ' ' + "${suffixes[i]}";
  }

  static String getName(String fullName) {
    final parts = fullName.split('/');
    return parts.skip(parts.length - 1).take(1).join('.');
  }
}
