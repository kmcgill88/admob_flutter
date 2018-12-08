import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class AdmobInterstitial {
  static Map<int, AdmobInterstitial> _allAds = <int, AdmobInterstitial>{};
  static const MethodChannel _channel =
      const MethodChannel('admob_flutter/interstitial');

  int id;
  final String adUnitId;

  AdmobInterstitial({@required this.adUnitId}) {
    id = hashCode;
    _allAds[id] = this;
  }

  Future<bool> get isLoaded async {
    final bool result = await _channel.invokeMethod('isLoaded', <String, dynamic>{
      'id': id,
    });
    return result;
  }

  void loadAd() {
    _channel.invokeMethod('load', <String, dynamic>{
      'id': id,
      'adUnitId': adUnitId,
    });
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

    _allAds.remove(id);
  }
}
