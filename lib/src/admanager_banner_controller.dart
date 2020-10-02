import 'package:admob_flutter/src/banner_controller.dart';
import 'admob_event_handler.dart';

class AdmanagerBannerController extends BannerController {
  AdmanagerBannerController(
      int id, Function(AdmobAdEvent, Map<String, dynamic>) listener)
      : super(id, listener, 'admob_flutter/admanager_banner');
}
