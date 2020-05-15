import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'admob_event_handler.dart';
import 'admob_targeting_targetinfo.dart';

class AdmobInterstitial extends AdmobEventHandler {
  static const MethodChannel _channel =
      MethodChannel('admob_flutter/interstitial');

  int id;
  MethodChannel _adChannel;
  final String adUnitId;
  final MobileAdTargetingInfo _targetingInfo;
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;

  AdmobInterstitial({
    @required this.adUnitId,
    this.listener,
    MobileAdTargetingInfo targetingInfo,
  })  : _targetingInfo = targetingInfo ?? const MobileAdTargetingInfo(),
        super(listener) {
    id = hashCode;

    if (listener != null) {
      _adChannel = MethodChannel('admob_flutter/interstitial_$id');
      _adChannel.setMethodCallHandler(handleEvent);
    }
  }

  Future<bool> get isLoaded async {
    final bool result =
        await _channel.invokeMethod('isLoaded', <String, dynamic>{
      'id': id,
    });
    return result;
  }

  void load() async {
    await _channel.invokeMethod('load', <String, dynamic>{
      'id': id,
      'adUnitId': adUnitId,
      'targetInfo': _targetingInfo?.toJson(),
    });

    if (listener != null) {
      await _channel.invokeMethod('setListener', <String, dynamic>{
        'id': id,
      });
    }
  }

  void show() async {
    if (await isLoaded == true) {
      await _channel.invokeMethod('show', <String, dynamic>{
        'id': id,
      });
    }
  }

  void dispose() async {
    await _channel.invokeMethod('dispose', <String, dynamic>{
      'id': id,
    });
  }
}
