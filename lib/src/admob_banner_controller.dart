import 'package:flutter/services.dart';
import 'admob_events.dart';

class AdmobBannerController {
  final MethodChannel _channel;
  final Function(AdmobAdEvent) _listener;

  AdmobBannerController(int id, Function(AdmobAdEvent) listener)
      : _channel = MethodChannel('admob_flutter/banner_$id'),
        _listener = listener {
        if (listener != null) {
          _channel.setMethodCallHandler(_handleMethod);
          _channel.invokeMethod('setListener');
        }
      }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'loaded':
        _listener(AdmobAdEvent.loaded);
        break;
      case 'failedToLoad':
        _listener(AdmobAdEvent.failedToLoad);
        break;
      case 'clicked':
        _listener(AdmobAdEvent.clicked);
        break;
      case 'impression':
        _listener(AdmobAdEvent.impression);
        break;
      case 'opened':
        _listener(AdmobAdEvent.opened);
        break;
      case 'leftApplication':
        _listener(AdmobAdEvent.leftApplication);
        break;
      case 'closed':
        _listener(AdmobAdEvent.closed);
        break;
    }

    return null;
  }

  void dispose() {
    _channel.invokeMethod('dispose');
  }
}
