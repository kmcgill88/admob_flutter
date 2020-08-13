import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'admob_event_handler.dart';

class AdmobInterstitial extends AdmobEventHandler {
  static const MethodChannel _channel =
      MethodChannel('admob_flutter/interstitial');

  int id;
  MethodChannel _adChannel;
  final String adUnitId;
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;

  AdmobInterstitial({
    @required this.adUnitId,
    this.listener,
  }) : super(listener) {
    id = hashCode;
  }

  Future<bool> get isLoaded async => false;

  void load() async {}

  void show() async {}

  void dispose() async {}
}
