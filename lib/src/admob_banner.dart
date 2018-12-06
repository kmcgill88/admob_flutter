import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'admob_banner_controller.dart';

class AdmobBanner extends StatefulWidget {
  final void Function(AdmobBannerController) onBannerCreated;

  AdmobBanner({
    Key key,
    this.onBannerCreated,
  }) : super(key: key);

  @override
  _AdmobBannerState createState() => _AdmobBannerState();
}

class _AdmobBannerState extends State<AdmobBanner> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'admob_flutter/banner',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'admob_flutter/banner',
        onPlatformViewCreated: _onPlatformViewCreated,
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
    if (widget.onBannerCreated == null) {
      return;
    }

    widget.onBannerCreated(AdmobBannerController(id));
  }
}
