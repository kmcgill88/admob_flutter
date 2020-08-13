import 'dart:async';

import 'package:meta/meta.dart';
import 'admob_event_handler.dart';

class AdmobReward extends AdmobEventHandler {
  int id;
  final String adUnitId;
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;

  AdmobReward({
    @required this.adUnitId,
    this.listener,
  }) : super(listener);

  Future<bool> get isLoaded async => false;

  void load() async {}

  void show() async {}

  void dispose() async {}
}
