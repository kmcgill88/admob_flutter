import 'admob_event_handler.dart';

class AdmobBannerController extends AdmobEventHandler {
  AdmobBannerController(
      int id, Function(AdmobAdEvent, Map<String, dynamic>) listener)
      : super(listener);

  void dispose() {}
}
