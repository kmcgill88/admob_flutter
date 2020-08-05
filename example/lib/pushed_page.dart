import 'package:flutter/material.dart';

import 'main.dart';

class PushedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pushed Page'),
        brightness: Brightness.dark,
      ).withAdmobBanner(context),
    );
  }
}
