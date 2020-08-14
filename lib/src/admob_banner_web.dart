import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'admob_banner_controller.dart';
import 'admob_banner_size.dart';
import 'admob_events.dart';

class AdmobBanner extends StatefulWidget {
  final String adUnitId;
  final AdmobBannerSize adSize;
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;
  final void Function(AdmobBannerController) onBannerCreated;

  AdmobBanner({
    Key key,
    @required this.adUnitId,
    @required this.adSize,
    this.listener,
    this.onBannerCreated,
  }) : super(key: key);

  @override
  _AdmobBannerState createState() => _AdmobBannerState();
}

class _AdmobBannerState extends State<AdmobBanner> {
  final UniqueKey _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final theKey = _key.toString();
    print('build' + theKey);

    // final key1 = theKey + 'script1';
    // final script1 = html.ScriptElement()
    //   ..type = 'text/javascript'
    //   // ..async = true
    //   ..src = 'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js'
    //   ..addEventListener('load', (event) {
    //     print('loaded111');
    //   });

    final key2 = theKey + 'script2';
    final script2 = html.ScriptElement()
      ..type = 'text/javascript'
      ..setInnerHtml('''
      var adsbygoogle = window.adsbygoogle || [];
      console.log("isLoaded: ", adsbygoogle);
      if (adsbygoogle.loaded) {
        console.log("adsense loaded. nothing to do here.");
      } else {
        console.log("needs to load")
        adsbygoogle.push({});
      }
      ''');

    final insTag = html.Element.tag('ins')
      ..attributes = {
        'class': 'adsbygoogle',
        'style': 'display:block',
        'data-ad-client': 'ca-pub-7570377070409946',
        'data-ad-slot': '2851567112',
        'data-ad-format': 'auto',
        'data-full-width-responsive': 'true',
      };

    final divElement = html.DivElement()
      ..style.backgroundColor = 'red'
      ..style.border = 'none'
      // ..append(script1)
      ..append(insTag)
      ..appendHtml('Hello Flutter Web')
      ..append(script2);

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      theKey,
      (int viewId) {
        return divElement;
      },
    );
    // ignore: undefined_prefixed_name
    // ui.platformViewRegistry.registerViewFactory(
    //   key1,
    //   (int viewId) {
    //     return script1;
    //   },
    // );
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      key2,
      (int viewId) {
        return script2;
      },
    );

    return HtmlElementView(
      key: _key,
      viewType: theKey,
    );
  }
}
