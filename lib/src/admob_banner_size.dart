import 'package:flutter/material.dart';

class AdmobBannerSize {
  final int width, height;
  final String? name;

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
  @deprecated
  AdmobBannerSize.SMART_BANNER(BuildContext context):
        width = MediaQuery.of(context).size.width.toInt(), height = -2, name = 'FLUID';
  AdmobBannerSize.ADAPTIVE_BANNER({required int width}):
      width = width, height = -2, name = 'ADAPTIVE_BANNER';
  AdmobBannerSize.FLUID(BuildContext context):
        width = MediaQuery.of(context).size.width.toInt(), height = -2, name = 'FLUID';

  const AdmobBannerSize({
    required this.width,
    required this.height,
    this.name,
  });

  bool get hasFixedSize => width > 0 && height > 0;

  Map<String, dynamic> get toMap => <String, dynamic>{
        'width': width,
        'height': height,
        'name': name,
      };
}
