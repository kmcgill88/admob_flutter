import 'package:admob_flutter/src/banner_controller.dart';
import 'admob_event_handler.dart';

class AdmobBannerController extends BannerController {
  AdmobBannerController(
      int id, Function(AdmobAdEvent, Map<String, dynamic>) listener)
      : super(id, listener, 'admob_flutter/banner');
}
