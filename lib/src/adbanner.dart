import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'admob_banner_size.dart';

abstract class AdBanner extends StatelessWidget {
  final String adUnitId;
  final AdmobBannerSize adSize;
  final Map<String, dynamic> targetInfo;
  final bool nonPersonalizedAds;
  final UniqueKey _key = UniqueKey();
  final String contentUrl;
  String get viewType;
  void onPlatformViewCreated(int id);

  AdBanner({
    Key key,
    @required this.adUnitId,
    @required this.adSize,
    this.targetInfo,
    this.contentUrl,
    this.nonPersonalizedAds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<Size>(
        future: adSize.futureSize,
        builder: (context, snapshot) {
          final _adSize = snapshot.data;
          if (_adSize == null) {
            return SizedBox.shrink();
          }
          if (defaultTargetPlatform == TargetPlatform.android) {
            return SizedBox.fromSize(
              size: _adSize,
              child: AndroidView(
                key: _key,
                viewType: viewType,
                creationParams: bannerCreationParams,
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: onPlatformViewCreated,
              ),
            );
          } else if (defaultTargetPlatform == TargetPlatform.iOS) {
            return SizedBox.fromSize(
              size: _adSize,
              child: UiKitView(
                key: _key,
                viewType: viewType,
                creationParams: bannerCreationParams,
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: onPlatformViewCreated,
              ),
            );
          }

          return Text(
              '$defaultTargetPlatform is not yet supported by the plugin');
        },
      );

  Map<String, dynamic> get bannerCreationParams => <String, dynamic>{
        'adUnitId': adUnitId,
        'adSize': adSize.toMap,
        'targetInfo': targetInfo,
        'nonPersonalizedAds': nonPersonalizedAds,
        'contentUrl': contentUrl,
      };
}
