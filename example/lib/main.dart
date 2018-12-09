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
  AdmobInterstitial interstitialAd;
  AdmobReward rewardAd;

  @override
  void initState() {
    super.initState();
    bannerSize = AdmobBannerSize.BANNER;

    interstitialAd = AdmobInterstitial(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      listener: (AdmobAdEvent event) {
        if (event == AdmobAdEvent.closed) {
          interstitialAd.load();
        }
      },
    );

    rewardAd = AdmobReward(
        adUnitId: 'ca-app-pub-3940256099942544/5224354917',
        listener: (AdmobAdEvent event) {
          if (event == AdmobAdEvent.closed) {
            rewardAd.load();
          }
        });

    interstitialAd.load();
    rewardAd.load();
  }

  void showSnackBar(BuildContext context, String content) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(content),
      duration: Duration(seconds: 1),
    ));
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
        ),
        bottomNavigationBar: Builder(
          builder: (BuildContext context) {
            return Container(
              height: 50,
              color: Colors.blueGrey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      child: Text(
                        'Show Interstitial',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (await interstitialAd.isLoaded)
                          interstitialAd.show();
                        else
                          showSnackBar(context, "Interstitial ad is still loading...");
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      child: Text(
                        'Show Reward',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (await rewardAd.isLoaded) {
                          rewardAd.show();
                        } else
                          showSnackBar(context, "Reward ad is still loading...");
                      },
                    ),
                  ),
                  Expanded(
                    child: PopupMenuButton(
                      initialValue: bannerSize,
                      child: Center(
                        child: Text(
                          'Banner size',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
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
                  ),
                ],
              ),
            );
          },
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
                      listener: (AdmobAdEvent event) {
                        switch (event) {
                          case AdmobAdEvent.loaded:
                            showSnackBar(context, "Admob Banner loaded!");
                            break;
                          case AdmobAdEvent.opened:
                            showSnackBar(context, "Admob Banner opened!");
                            break;
                          case AdmobAdEvent.closed:
                            showSnackBar(context, "Admob Banner closed!");
                            break;
                          default:
                        }
                      },
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
