# admob_flutter

![Demo](https://i.imgur.com/zJC41es.gif)

A new Flutter plugin that uses native platform views to show Admob banner ads!

This plugin also has support for Interstitial and Reward ads.

This is an early version of the plugin, my primary goal was to overcome the banner ads positioning limitations by implementing a platform views solution, and keeping things simple and stupid because I'm still learning about many Flutter related stuff. I will actively work on adding missing features, improving, and refactoring the code in my free time.

**Currently working on Android only, but iOS support will be available so soon.**

If you enjoy my work, please consider making a donation! Your donations will help me have more time to make more helpful plugins and maintain them.

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/YoussefKababe)

## Installation

Add this to your pubspec.yml dependencies:

```yaml
admob_flutter: "^0.1.2"
```

## How to use

### Update your AndroidManifest.xml

Add your AdMob App ID to your app's AndroidManifest.xml file by adding the <meta-data> tag shown below. You can find your App ID in the AdMob UI. For android:value insert your own AdMob App ID in quotes, as shown below.

You can use this test App ID from Admob for development:
```
ca-app-pub-3940256099942544~3347511713
```

```xml
<manifest>
  <application>
    <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-3940256099942544~3347511713"/>
  </application>
</manifest>
```

### Initialize the plugin

First thing to do before attempting to show any ads is to initialize the plugin. You can do this in the earliest starting point of your app, your `main` function:

```dart
import 'package:admob_flutter/admob_flutter.dart';

void main() {
  Admob.initialize('ca-app-pub-3940256099942544~3347511713');
  runApp(MyApp());
}
```

### Showing Banner Ads

This plugin uses Native Platform Views to show Admob banner ads thus, same as any other widget, there's no limitations on where to place your banners.

```dart
AdmobBanner(
  adUnitId: 'ca-app-pub-3940256099942544/6300978111',
  adSize: AdmobBannerSize.BANNER,
)
```

### Banner Ads sizes

The plugin provides all banner sizes supported by Admob, and will wrap the banner with a correctly sized `Container` so you don't worry about your ad displaying incorrectly:

- `AdmobBannerSize.Banner`: 320x50
- `AdmobBannerSize.LARGE_BANNER`: 320x100
- `AdmobBannerSize.MEDIUM_RECTANGLE`: 300x250
- `AdmobBannerSize.FULL_BANNER`: 468x60
- `AdmobBannerSize.LEADERBOARD`: 728x90
- `AdmobBannerSize.SMART_BANNER`: Wrap in a container with a size of your choice

### Listening to Banner Ads events

You can attach a listener to your ads in order to customize their behavior like this:

```dart
AdmobBanner(
  adUnitId: 'ca-app-pub-3940256099942544/6300978111',
  adSize: AdmobBannerSize.BANNER,
  listener: (AdmobAdEvent event, Map<String, dynamic> args) {
    switch (event) {
      case AdmobAdEvent.loaded:
        print('Admob banner loaded!');
        break;

      case AdmobAdEvent.opened:
        print('Admob banner opened!');
        break;

      case AdmobAdEvent.closed:
        print('Admob banner closed!');
        break;

      case AdmobAdEvent.failedToLoad:
        print('Admob banner failed to load. Error code: ${args['errorCode']}');
        break;
    }
  }
)
```

### Showing Interstitial Ads

```dart
// First, create an interstitial ad
AdmobInterstitial interstitialAd = AdmobInterstitial(
  adUnitId: 'ca-app-pub-3940256099942544/1033173712',
);

// Interstitials must be loaded before shown.
// Make sure to always load them ahead so they can be
// available to be shown immediately to the user
interstitialAd.load();

// Check if the ad is loaded and then show it
if (await interstitialAd.isLoaded) {
  interstitialAd.show();
}

// Finally, make sure you dispose the ad if you're done with it
interstitialAd.dispose();
```

### Listening to Interstitial Ads events

Same as banner ads, you can attach a listener to interstitials too. For example if you wish to:
- Show the interstitial as soon as it is loaded
- Load a new ad and show it as soon as the old one is closed
- Get your users stuck in an interstitial ads loop to maximize revenue
- Get your Admob account banned and lose all your earnings

You can do something like this (Don't do it!):

```dart
AdmobInterstitial interstitialAd;

interstitialAd = AdmobInterstitial(
  adUnitId: 'ca-app-pub-3940256099942544/1033173712',
  listener: (AdmobAdEvent event, Map<String, dynamic> args) {
    if (event == AdmobAdEvent.loaded) interstitialAd.show();
    if (event == AdmobAdEvent.closed) interstitialAd.load();
    if (event == AdmobAdEvent.failedToLoad) {
      // Start hoping they didn't just ban your account :)
      print("Error code: ${args['errorCode']}");
    }
  },
);
```

### Showing Reward Ads

```dart
// First, create a reward ad
AdmobReward rewardAd = AdmobReward(
  adUnitId: 'ca-app-pub-3940256099942544/5224354917',
);

// Reward ads must be loaded before shown.
// Make sure to always load them ahead so they can be
// available to be shown immediately to the user
rewardAd.load();

// Check if the ad is loaded and then show it
if (await rewardAd.isLoaded) {
  rewardAd.show();
}

// Finally, make sure you dispose the ad if you're done with it
rewardAd.dispose();
```

### Listening to Reward Ads events

Listening to reward ads events works the same as with banners and interstitials, except that rewards have some additional events. One of them is the `rewarded` event which you should listen to so you know whether your users have earned the reward or not:

```dart
AdmobReward rewardAd = AdmobReward(
  adUnitId: 'ca-app-pub-3940256099942544/5224354917',
  listener: (AdmobAdEvent event, Map<String, dynamic> args) {
    if (event == AdmobAdEvent.rewarded) {
      print('User was rewarded!');
      print('Reward type: ${args['type']}');
      print('Reward amount: ${args['amount']}');
    }
  },
);
```

### Showing Native Ads

**Coming soon!**

### Using targeting info

**Coming soon!**
