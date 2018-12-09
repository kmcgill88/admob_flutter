import 'package:flutter/services.dart';

import 'admob_events.dart';
export 'admob_events.dart';

abstract class AdmobEventHandler {
  final Function(AdmobAdEvent) _listener;

  AdmobEventHandler(Function(AdmobAdEvent) listener) : _listener = listener;

  Future<dynamic> handleEvent(MethodCall call) async {
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
}
