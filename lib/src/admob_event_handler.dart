import 'dart:async';

import 'package:flutter/services.dart';

import 'admob_events.dart';
export 'admob_events.dart';

abstract class AdmobEventHandler {
  final Function(AdmobAdEvent, Map<String, dynamic>?)? _listener;

  AdmobEventHandler(Function(AdmobAdEvent, Map<String, dynamic>?)? listener)
      : _listener = listener;

  Future<dynamic> handleEvent(MethodCall call) async {
    if (_listener == null) return null;
    switch (call.method) {
      case 'loaded':
        _listener!.call(AdmobAdEvent.loaded, null);
        break;
      case 'failedToLoad':
        _listener!.call(AdmobAdEvent.failedToLoad,
            Map<String, dynamic>.from(call.arguments));
        break;
      case 'clicked':
        _listener!.call(AdmobAdEvent.clicked, null);
        break;
      case 'impression':
        _listener!.call(AdmobAdEvent.impression, null);
        break;
      case 'opened':
        _listener!.call(AdmobAdEvent.opened, null);
        break;
      case 'leftApplication':
        _listener!.call(AdmobAdEvent.leftApplication, null);
        break;
      case 'closed':
        _listener!.call(AdmobAdEvent.closed, null);
        break;
      case 'completed':
        _listener!.call(AdmobAdEvent.completed, null);
        break;
      case 'rewarded':
        _listener!.call(
            AdmobAdEvent.rewarded, Map<String, dynamic>.from(call.arguments));
        break;
      case 'started':
        _listener!.call(AdmobAdEvent.started, null);
        break;
    }
  }
}
