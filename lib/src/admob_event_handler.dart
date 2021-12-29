import 'dart:async';

import 'package:flutter/services.dart';

import 'admob_events.dart';
export 'admob_events.dart';

abstract class AdmobEventHandler {
  final Function(AdmobAdEvent, Map<String, dynamic>?)? _listener;

  AdmobEventHandler(Function(AdmobAdEvent, Map<String, dynamic>?)? listener)
      : _listener = listener;

  Future<void> handleEvent(MethodCall call) async {
    if (_listener == null) {
      return;
    }
    switch (call.method) {
      case 'loaded':
        _listener!(AdmobAdEvent.loaded, null);
        break;
      case 'failedToLoad':
        _listener!(AdmobAdEvent.failedToLoad,
            Map<String, dynamic>.from(call.arguments));
        break;
      case 'clicked':
        _listener!(AdmobAdEvent.clicked, null);
        break;
      case 'impression':
        _listener!(AdmobAdEvent.impression, null);
        break;
      case 'opened':
        _listener!(AdmobAdEvent.opened, null);
        break;
      case 'closed':
        _listener!(AdmobAdEvent.closed, null);
        break;
      case 'completed':
        _listener!(AdmobAdEvent.completed, null);
        break;
      case 'rewarded':
        _listener!(
            AdmobAdEvent.rewarded, Map<String, dynamic>.from(call.arguments));
        break;
      case 'started':
        _listener!(AdmobAdEvent.started, null);
        break;
    }
  }
}
