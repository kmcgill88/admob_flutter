import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class AdmobBannerSize {
  final int width, height;
  final String name;

  static const AdmobBannerSize BANNER =
      AdmobBannerSize(width: 320, height: 50, name: 'BANNER');
  static const AdmobBannerSize LARGE_BANNER =
      AdmobBannerSize(width: 320, height: 100, name: 'LARGE_BANNER');
  static const AdmobBannerSize MEDIUM_RECTANGLE =
      AdmobBannerSize(width: 300, height: 250, name: 'MEDIUM_RECTANGLE');
  static const AdmobBannerSize FULL_BANNER =
      AdmobBannerSize(width: 468, height: 60, name: 'FULL_BANNER');
  static const AdmobBannerSize LEADERBOARD =
      AdmobBannerSize(width: 728, height: 90, name: 'LEADERBOARD');
  AdmobBannerSize.SMART_BANNER(BuildContext context):
        this.width = MediaQuery.of(context).size.width.toInt(), this.height = -2, this.name = 'SMART_BANNER';
  AdmobBannerSize.ADAPTIVE_BANNER({@required int width}):
      this.width = width, this.height = -2, this.name = 'ADAPTIVE_BANNER';

  const AdmobBannerSize({
    @required this.width,
    @required this.height,
    this.name,
  });

  bool get hasFixedSize => width > 0 && height > 0;

  Map<String, dynamic> get toMap => <String, dynamic>{
        'width': width,
        'height': height,
        'name': name,
      };
}
