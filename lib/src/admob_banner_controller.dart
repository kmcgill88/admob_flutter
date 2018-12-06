import 'package:flutter/services.dart';

class AdmobBannerController {
  final MethodChannel _channel;

  AdmobBannerController(int id) : _channel = MethodChannel('admob_flutter/banner_$id');
}
