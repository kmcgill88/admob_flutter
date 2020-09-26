import 'package:admob_flutter_example/extensions.dart';
import 'package:flutter/material.dart';

class NewPage extends StatelessWidget {
  final String title;
  const NewPage({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        brightness: Brightness.dark,
      ).withBottomAdmobBanner(context),
      body: Container(
        color: Colors.green,
      ),
    );
  }
}
