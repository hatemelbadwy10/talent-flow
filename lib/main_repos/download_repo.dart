import 'dart:io';

import 'package:dio/dio.dart';

class DownloadRepo {
  DownloadRepo();
  final Dio _dio = Dio();

  download({required String url, required String path, Function(int, int)? onReceiveProgress}) async {
    return await _dio.download(
      url,
      path,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        headers: {
          HttpHeaders.acceptEncodingHeader: "*",
        },
      ),
    );
  }
}
