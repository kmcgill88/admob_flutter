import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'admob.dart';
import 'admob_banner_controller.dart';
import 'admob_banner_size.dart';
import 'admob_events.dart';

class AdmobBanner extends StatefulWidget {
  final String adUnitId;
  final AdmobBannerSize adSize;
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;
  final void Function(AdmobBannerController) onBannerCreated;
  final bool nonPersonalizedAds;

  AdmobBanner({
    Key key,
    @required this.adUnitId,
    @required this.adSize,
    this.listener,
    this.onBannerCreated,
    this.nonPersonalizedAds = false,
  }) : super(key: key);

  static String get testAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  _AdmobBannerState createState() => _AdmobBannerState();
}

class _AdmobBannerState extends State<AdmobBanner> {
  final UniqueKey _key = UniqueKey();
  AdmobBannerController _controller;
  Future<Size> adSize;

  @override
  void initState() {
    super.initState();

    if (!widget.adSize.hasFixedSize) {
      adSize = Admob.bannerSize(widget.adSize);
    } else {
      adSize = Future.value(Size(
        widget.adSize.width.toDouble(),
        widget.adSize.height.toDouble(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Size>(
      future: adSize,
      builder: (context, snapshot) {
        final adSize = snapshot.data;
        if (adSize == null) {
          return SizedBox.shrink();
        }

        if (defaultTargetPlatform == TargetPlatform.android) {
          return SizedBox.fromSize(
            size: adSize,
            child: AndroidView(
              key: _key,
              viewType: 'admob_flutter/banner',
              creationParams: bannerCreationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onPlatformViewCreated,
            ),
          );
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          return SizedBox.fromSize(
            size: adSize,
            child: UiKitView(
              key: _key,
              viewType: 'admob_flutter/banner',
              creationParams: bannerCreationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onPlatformViewCreated,
            ),
          );
        }

        return Text('$defaultTargetPlatform is not yet supported by the plugin');
      },
    );
  }

  void _onPlatformViewCreated(int id) {
    _controller = AdmobBannerController(id, widget.listener);

    if (widget.onBannerCreated != null) {
      widget.onBannerCreated(_controller);
    }
  }

  Map<String, dynamic> get bannerCreationParams => <String, dynamic>{
    'adUnitId': widget.adUnitId,
    'adSize': widget.adSize.toMap,
    'nonPersonalizedAds': widget.nonPersonalizedAds,
  };
}
