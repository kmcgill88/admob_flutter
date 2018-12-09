import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'admob_event_handler.dart';

class AdmobInterstitial extends AdmobEventHandler {
  static const MethodChannel _channel =
      const MethodChannel('admob_flutter/interstitial');

  int id;
  final String adUnitId;
  final void Function(AdmobAdEvent) listener;

  AdmobInterstitial({
    @required this.adUnitId,
    this.listener,
  }) : super(listener) {
    id = hashCode;
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
    });

    if (listener != null) {
      MethodChannel adChannel = MethodChannel('admob_flutter/interstitial_$id');
      adChannel.setMethodCallHandler(handleEvent);

      _channel.invokeMethod('setListener', <String, dynamic>{
        'id': id,
      });
    }
  }

  void show() async {
    if (await isLoaded == true) {
      _channel.invokeMethod('show', <String, dynamic>{
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
