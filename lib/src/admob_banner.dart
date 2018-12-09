import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'admob_banner_controller.dart';
import 'admob_banner_size.dart';
import 'admob_events.dart';

class AdmobBanner extends StatefulWidget {
  final String adUnitId;
  final AdmobBannerSize adSize;
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;
  final void Function(AdmobBannerController) onBannerCreated;

  AdmobBanner({
    Key key,
    @required this.adUnitId,
    @required this.adSize,
    this.listener,
    this.onBannerCreated,
  }) : super(key: key);

  @override
  _AdmobBannerState createState() => _AdmobBannerState();
}

class _AdmobBannerState extends State<AdmobBanner> {
  AdmobBannerController _controller;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: widget.adSize.width >= 0 ? widget.adSize.width.toDouble() : double.infinity,
        height: widget.adSize.height >= 0 ? widget.adSize.height.toDouble() : double.infinity,
        child: AndroidView(
          key: UniqueKey(),
          viewType: 'admob_flutter/banner',
          creationParams: <String, dynamic>{
            "adUnitId": widget.adUnitId,
            "adSize": widget.adSize.toMap,
          },
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        key: UniqueKey(),
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: UiKitView(
          viewType: 'admob_flutter/banner',
          creationParams: <String, dynamic>{
            "adUnitId": widget.adUnitId,
            "adSize": widget.adSize.toMap,
          },
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    } else {
      return Text('$defaultTargetPlatform is not yet supported by the plugin');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _controller = AdmobBannerController(id, widget.listener);

    if (widget.onBannerCreated != null) {
      widget.onBannerCreated(_controller);
    }
  }
}
