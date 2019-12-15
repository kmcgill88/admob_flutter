import 'dart:io';

import 'package:flutter/material.dart';

import 'package:admob_flutter/admob_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize(getAppId());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  AdmobReward rewardAd;

  @override
  void initState() {
    super.initState();
    bannerSize = AdmobBannerSize.BANNER;

    interstitialAd = AdmobInterstitial(
      adUnitId: getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
        handleEvent(event, args, 'Interstitial');
      },
    );

    rewardAd = AdmobReward(
        adUnitId: getRewardBasedVideoAdUnitId(),
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          if (event == AdmobAdEvent.closed) rewardAd.load();
          handleEvent(event, args, 'Reward');
        });

    interstitialAd.load();
    rewardAd.load();
  }

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        showSnackBar('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        showSnackBar('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        showSnackBar('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        showSnackBar('Admob $adType failed to load. :(');
        break;
      case AdmobAdEvent.rewarded:
        showDialog(
          context: scaffoldState.currentContext,
          builder: (BuildContext context) {
            return WillPopScope(
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Reward callback fired. Thanks Andrew!'),
                    Text('Type: ${args['type']}'),
                    Text('Amount: ${args['amount']}'),
                  ],
                ),
              ),
              onWillPop: () async {
                scaffoldState.currentState.hideCurrentSnackBar();
                return true;
              },
            );
          },
        );
        break;
      default:
    }
  }

  void showSnackBar(String content) {
    scaffoldState.currentState.showSnackBar(SnackBar(
      content: Text(content),
      duration: Duration(milliseconds: 1500),
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
        key: scaffoldState,
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
                        if (await interstitialAd.isLoaded) {
                          interstitialAd.show();
                        } else {
                          showSnackBar("Interstitial ad is still loading...");
                        }
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
                        } else {
                          showSnackBar("Reward ad is still loading...");
                        }
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
                      adUnitId: getBannerAdUnitId(),
                      adSize: bannerSize,
                      listener:
                          (AdmobAdEvent event, Map<String, dynamic> args) {
                        handleEvent(event, args, 'Banner');
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

  @override
  void dispose() {
    interstitialAd.dispose();
    rewardAd.dispose();
    super.dispose();
  }
}

/*
Test Id's from:
https://developers.google.com/admob/ios/banner
https://developers.google.com/admob/android/banner

App Id
Android: ca-app-pub-3940256099942544~3347511713
iOS: ca-app-pub-3940256099942544~1458002511

Banner
Android: ca-app-pub-3940256099942544/6300978111
iOS: ca-app-pub-3940256099942544/2934735716

Interstitial
Android: ca-app-pub-3940256099942544/1033173712
iOS: ca-app-pub-3940256099942544/4411468910

Reward Video
Android: ca-app-pub-3940256099942544/5224354917
iOS: ca-app-pub-3940256099942544/1712485313
*/

String getAppId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544~1458002511';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544~3347511713';
  }
  return null;
}

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
  }
  return null;
}

String getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/4411468910';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/1033173712';
  }
  return null;
}

String getRewardBasedVideoAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/1712485313';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/5224354917';
  }
  return null;
}

