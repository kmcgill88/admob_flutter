import 'package:flutter/services.dart';
import 'admob_event_handler.dart';

class BannerController extends AdmobEventHandler {
  final MethodChannel _channel;

  BannerController(int id,
      Function(AdmobAdEvent, Map<String, dynamic>) listener, String name)
      : _channel = MethodChannel('${name}_$id'),
        super(listener) {
    if (listener != null) {
      _channel.setMethodCallHandler(handleEvent);
      _channel.invokeMethod('setListener');
    }
  }

  void dispose() {
    _channel.invokeMethod('dispose');
  }
}
