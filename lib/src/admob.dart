import 'package:flutter/services.dart';

class Admob {
  static const MethodChannel _channel = const MethodChannel('admob_flutter');

  static void initialize(String appID) {
    _channel.invokeMethod('initialize', appID);
  }
}
