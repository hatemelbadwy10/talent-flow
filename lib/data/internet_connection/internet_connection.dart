import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import '../../app/core/app_core.dart';
import '../../app/core/text_styles.dart';
import '../../app/localization/language_constant.dart';
import '../../navigation/custom_navigation.dart';

class InternetConnection {
  final Connectivity connectivity;
  InternetConnection({required this.connectivity});

  bool showDialog = false;

  StreamSubscription<List<ConnectivityResult>> connectionStream(onVisible) {
    return connectivity.onConnectivityChanged
        .listen((v) => checkConnectivity(result: v, onVisible: onVisible));
  }

  checkConnectivity(
      {required List<ConnectivityResult> result, Function()? onVisible}) async {
    bool isNotConnected;
    if (result.contains(ConnectivityResult.none)) {
      isNotConnected = true;
    } else {
      isNotConnected = !await updateConnectivityStatus();
    }

    isNotConnected ? null : AppCore.hideSnackBar();
    if(isNotConnected) {
      Timer(Duration.zero, () {
      CustomNavigator.scaffoldState.currentState!.showSnackBar(
        SnackBar(
          margin: EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
            vertical: Dimensions.PADDING_SIZE_DEFAULT.h,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
            vertical: Dimensions.PADDING_SIZE_DEFAULT.h,
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.6),)),
          content: Row(
            children: [
              Icon(
                !isNotConnected ? Icons.wifi : Icons.wifi_off_sharp,
                color: Colors.white,
              ),
              SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT.w),
              Expanded(
                child: Text(
                  getTranslated(
                      !isNotConnected ? "connected" : "no_connection"),
                  style: AppTextStyles.w600
                      .copyWith(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey.withOpacity(0.6),
        ),
      );
    });
    }

    log("===> onConnectivityChanged${result.toString()}");
    log("===> isNotConnected $isNotConnected");
    log("===> showDialog $showDialog");
  }

  Future<bool> updateConnectivityStatus() async {
    bool isConnected = true;
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } catch (e) {
      isConnected = false;
    }
    return isConnected;
  }

  Future<String> _updateConnectionMessage(
      List<ConnectivityResult> result) async {
    switch (result.last) {
      case ConnectivityResult.wifi:
        return 'Connected to WiFi';
      case ConnectivityResult.mobile:
        return 'Connected to Mobile Network';
      case ConnectivityResult.none:
        return 'No Internet Connection';
      default:
        return 'No Internet Connection';
    }
  }
}
