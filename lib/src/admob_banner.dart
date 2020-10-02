import 'package:admob_flutter/src/adbanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'admob_banner_controller.dart';
import 'admob_banner_size.dart';
import 'admob_events.dart';

class AdmobBanner extends AdBanner {
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;
  final Function(AdmobBannerController) onBannerCreated;
  static const String viewTypeName = 'admob_flutter/banner';
  AdmobBanner({
    Key key,
    @required String adUnitId,
    @required AdmobBannerSize adSize,
    bool nonPersonalizedAds = false,
    String contentUrl,
    this.onBannerCreated,
    this.listener,
  }) : super(
          key: key,
          adUnitId: adUnitId,
          contentUrl: contentUrl,
          adSize: adSize,
          nonPersonalizedAds: nonPersonalizedAds,
        );
  @override
  String get viewType => viewTypeName;

  @override
  void onPlatformViewCreated(int id) {
    final controller = AdmobBannerController(id, listener);
    if (onBannerCreated != null) {
      onBannerCreated(controller);
    }
  }
}
