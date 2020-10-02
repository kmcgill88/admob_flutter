import 'package:admob_flutter/src/adbanner.dart';
import 'package:admob_flutter/src/admanager_banner_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'admob_banner_size.dart';
import 'admob_events.dart';

class AdmanagerBanner extends AdBanner {
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;
  final Function(AdmanagerBannerController) onBannerCreated;
  static const String viewTypeName = 'admob_flutter/admanager_banner';

  AdmanagerBanner({
    Key key,
    @required String adUnitId,
    @required AdmobBannerSize adSize,
    bool nonPersonalizedAds = false,
    Map<String, dynamic> targetInfo = const {},
    String contentUrl,
    this.onBannerCreated,
    this.listener,
  }) : super(
          key: key,
          adUnitId: adUnitId,
          adSize: adSize,
          nonPersonalizedAds: nonPersonalizedAds,
          contentUrl: contentUrl,
          targetInfo: targetInfo,
        );

  @override
  String get viewType => viewTypeName;

  @override
  void onPlatformViewCreated(int id) {
    final controller = AdmanagerBannerController(id, listener);
    if (onBannerCreated != null) {
      onBannerCreated(controller);
    }
  }
}
