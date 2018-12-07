import 'package:flutter/material.dart';

import 'package:admob_flutter/admob_flutter.dart';

void main() {
  Admob.initialize('ca-app-pub-3940256099942544~3347511713');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AdmobBannerSize bannerSize;

  @override
  void initState() {
    bannerSize = AdmobBannerSize.BANNER;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AdmobFlutter'),
          actions: <Widget>[
            PopupMenuButton(
              initialValue: bannerSize,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 16, left: 16),
                  child: Text('Change banner size'),
                ),
              ),
              offset: Offset(0, 20),
              onSelected: (AdmobBannerSize newSize) {
                setState(() {
                  bannerSize = newSize;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<AdmobBannerSize>>[
                    PopupMenuItem(
                      value: AdmobBannerSize.BANNER,
                      child: Text('BANNER'),
                    ),
                    PopupMenuItem(
                      value: AdmobBannerSize.LARGE_BANNER,
                      child: Text('LARGE_BANNER'),
                    ),
                    PopupMenuItem(
                      value: AdmobBannerSize.MEDIUM_RECTANGLE,
                      child: Text('MEDIUM_RECTANGLE'),
                    ),
                    PopupMenuItem(
                      value: AdmobBannerSize.FULL_BANNER,
                      child: Text('FULL_BANNER'),
                    ),
                    PopupMenuItem(
                      value: AdmobBannerSize.LEADERBOARD,
                      child: Text('LEADERBOARD'),
                    ),
                    PopupMenuItem(
                      value: AdmobBannerSize.SMART_BANNER,
                      child: Text('SMART_BANNER'),
                    ),
                  ],
            ),
          ],
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(20.0),
          itemCount: 1000,
          itemBuilder: (BuildContext context, int index) {
            if (index != 0 && index % 6 == 0) {
              return Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: AdmobBanner(
                      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
                      adSize: bannerSize,
                    ),
                  ),
                  Container(
                    height: 200.0,
                    margin: EdgeInsets.only(bottom: 20.0),
                    color: Colors.cyan,
                  ),
                ],
              );
            }
            return Container(
              height: 200.0,
              margin: EdgeInsets.only(bottom: 20.0),
              color: Colors.cyan,
            );
          },
        ),
      ),
    );
  }
}
