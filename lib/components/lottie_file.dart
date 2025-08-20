import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

abstract class LottieFile {
  static LottieBuilder asset(String name,
      {double? height, double? width, BoxFit? fit}) {
    return Lottie.asset(
      "assets/json/$name.json",
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
    );
  }

  static LottieBuilder network(String url,
      {double? height, double? width, BoxFit? fit}) {
    return Lottie.network(
      url,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
    );
  }
}
