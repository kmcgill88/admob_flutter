# Announcement: I'm looking for a maintainer

I'm really sorry to announce this, but my schedules have been too tight for me the last months that I can't find good time to maintain this project. I'm looking for a possible maintainer to transfer this project to, someone who is sure to perfectly handle it and keep it updated. Please drop me a message on [youssef.kbe@gmail.com](mailto:youssef.kbe@gmail.com).

# admob_flutter
[![version](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://github.com/Solido/awesome-flutter/)
[![version](https://img.shields.io/pub/v/admob_flutter.svg?style=flat-square)](https://pub.dartlang.org/packages/admob_flutter)
[![GitHub stars](https://img.shields.io/github/stars/YoussefKababe/admob_flutter.svg?style=social&label=Star)](https://github/YoussefKababe/admob_flutter)
[![GitHub forks](	https://img.shields.io/github/forks/YoussefKababe/admob_flutter.svg?style=social&label=Forks)](https://github/YoussefKababe/admob_flutter)
[![GitHub issues](	https://img.shields.io/github/issues/YoussefKababe/admob_flutter.svg?style=social&label=Issues)](https://github/YoussefKababe/admob_flutter)



![Demo](https://i.imgur.com/zJC41es.gif)

A new Flutter plugin that uses native platform views to show Admob banner ads!

This plugin also has support for Interstitial and Reward ads.

This is an early version of the plugin, my primary goal was to overcome the banner ads positioning limitations by implementing a platform views solution, and keeping things simple and stupid because I'm still learning about many Flutter related stuff. I will actively work on adding missing features, improving, and refactoring the code in my free time.

# Installation

1. Depend on it
Add this to your package's pubspec.yaml file:

```dart
dependencies:
  admob_flutter: "^0.3.1"

```

2. Install it
You can install packages from the command line:

with Flutter:

```dart
$ flutter pub get
```

Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more.

3. Import it
Now in your Dart code, you can use:

```dart
import 'package:admob_flutter/admob_flutter.dart';
```
  

### Supported Platforms
- `0.3.0` >= iOS
- `0.2.0` >= AndroidX
- FlutterSdk >=2.1.0 < 3.0.0

### Supported Admob features
- Banner Ads
- Interstitial Ads
- Reward Ads
- Native Ads (Coming soon)

### View the rest documentation on the [repository Wiki](https://github.com/YoussefKababe/admob_flutter/wiki)! 

# Pull Requests

I welcome and encourage all pull requests. Here are some basic rules to follow to ensure timely addition of your request:

1.  Match the document style as closely as possible.
2.  Please keep PR titles easy to read and descriptive of changes, this will make them easier to review/merge.
3.  Pull requests _must_ be made against `master` branch for this repository.
4.  Check for existing [issues](https://github.com/iampawan/FlutterExampleApps/issues) first, before filing an issue.
5.  Have fun!
