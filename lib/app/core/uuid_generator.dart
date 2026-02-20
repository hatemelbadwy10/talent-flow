import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';


abstract class UUIDGenerator{
  static Future<String> generate() async{
    String uuid = "" ;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if(Platform.isIOS){
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      uuid = iosInfo.identifierForVendor ?? "";
    }else if(Platform.isAndroid){
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      uuid = androidInfo.id ;
    }


    return uuid;
  }
}