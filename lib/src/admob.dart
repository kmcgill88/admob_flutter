import 'dart:async';
import 'package:flutter/services.dart';

class Admob {
  static const MethodChannel _channel = const MethodChannel('admob_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  // Initialize the ads SDK
  static void initialize(String appID) {
    _channel.invokeMethod('initialize', appID);
  }
}
