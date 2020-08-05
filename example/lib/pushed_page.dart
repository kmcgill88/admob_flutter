import 'package:admob_flutter_example/extensions.dart';
import 'package:flutter/material.dart';


class PushedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pushed Page'),
        brightness: Brightness.dark,
      ).withBottomAdmobBanner(context),
    );
  }
}
