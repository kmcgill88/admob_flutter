import 'dart:io';
import 'dart:math';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:admob_flutter_example/extensions.dart';
import 'package:admob_flutter_example/pushed_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize without device test ids
  Admob.initialize();

  // Add a list of test ids.
  // Admob.initialize(testDeviceIds: ['YOUR DEVICE ID']);

  // runApp(TopBannerAdAppRecipe(child: MyMaterialApp()));

  runApp(MyMaterialApp());
}

class TopBannerAdAppRecipe extends StatelessWidget {
  const TopBannerAdAppRecipe({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery(
        data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
        child: Container(
          color: Colors.blueGrey,
          child: Column(children: [
            SafeArea(
              bottom: false,
              child: Builder(
                builder: (BuildContext context) {
                  final size = MediaQuery.of(context).size;
                  final height = max(size.height * .05, 50.0);
                  return Container(
                    width: size.width,
                    height: height,
                    child: AdmobBanner(
                      adUnitId: getBannerAdUnitId(),
                      adSize: AdmobBannerSize.ADAPTIVE_BANNER(
                        width: size.width.toInt(),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(child: child),
          ]),
        ),
      ),
    );
  }
}

class MyMaterialApp extends StatefulWidget {
  @override
  _MyMaterialAppState createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  AdmobInterstitial interstitialAd;
  AdmobReward rewardAd;

  @override
  void initState() {
    super.initState();

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
      },
    );

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
    scaffoldState.currentState.showSnackBar(
      SnackBar(
        content: Text(content),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          key: scaffoldState,
          appBar: AppBar(
            title: const Text('AdmobFlutter'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (BuildContext context) {
                        return PushedPage();
                      },
                    ),
                  );
                },
                child: Text(
                  'Open',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ).withBottomAdmobBanner(context),
          bottomNavigationBar: Builder(
            builder: (BuildContext context) {
              return Container(
                color: Colors.blueGrey,
                child: SizedBox(
                  height: 60,
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
                              showSnackBar(
                                  'Interstitial ad is still loading...');
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
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
                              showSnackBar('Reward ad is still loading...');
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          child: Text(
                            'Banners',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return PushedPage();
                              }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          body: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    padding: EdgeInsets.all(20.0),
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 100.0,
                        margin: EdgeInsets.only(bottom: 20.0),
                        color: Colors.cyan,
                      );
                    },
                  ),
                ),
              ),
              // Another option is to fix a banner ad to the top or bottom of your content.
              // Notice that banners are not scrolling, which is a violation of admob policy.
              //
              // See: https://github.com/kmcgill88/admob_flutter/issues/194
              // "banner ads should not move as a user scrolls, as users may try to
              // click on the menu but end up clicking on the ad accidentally instead.
              // This specific implementation is against policy and we reserve the right
              // to disable ad serving to your app."

              // Builder(
              //   builder: (BuildContext context) {
              //     final size = MediaQuery.of(context).size;
              //     final height = max(size.height * .05, 50.0);
              //     return Container(
              //       width: size.width,
              //       height: height,
              //       child: AdmobBanner(
              //         adUnitId: getBannerAdUnitId(),
              //         adSize: AdmobBannerSize.ADAPTIVE_BANNER(
              //           width: size.width.toInt(),
              //         ),
              //         listener: (AdmobAdEvent event, Map<String, dynamic> args) {
              //           handleEvent(event, args, 'Banner');
              //         },
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    ).withBottomAdmobBanner(context);
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

App Id - See README where these Id's go
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
