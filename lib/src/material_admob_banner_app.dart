import 'dart:math';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';

class MaterialAdmobBannerApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  final Widget home;
  final Map<String, WidgetBuilder> routes;
  final String initialRoute;
  final RouteFactory onGenerateRoute;
  final InitialRouteListFactory onGenerateInitialRoutes;
  final RouteFactory onUnknownRoute;
  final List<NavigatorObserver> navigatorObservers;
  final TransitionBuilder builder;
  final String title;
  final GenerateAppTitle onGenerateTitle;
  final ThemeData theme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;
  final Color color;
  final Locale locale;
  final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates;
  final LocaleListResolutionCallback localeListResolutionCallback;
  final LocaleResolutionCallback localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final Map<LogicalKeySet, Intent> shortcuts;
  final Map<Type, Action<Intent>> actions;
  final bool debugShowMaterialGrid;
  final Key materialAppKey;
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;
  final void Function(AdmobBannerController) onBannerCreated;

  final String adUnitId;
  final Color windowColor;
  final bool bannerIsBottom;
  final double bannerHeightFixed;
  final double bannerHeightPercentage;

  MaterialAdmobBannerApp({
    /// MaterialAdmobBannerApp specific
    ///
    @required this.adUnitId,
    this.bannerIsBottom = true,
    this.bannerHeightFixed,
    this.bannerHeightPercentage,
    this.windowColor,
    this.listener,
    this.onBannerCreated,
    Key materialAdmobBannerAppKey,

    /// MaterialApp
    ///
    this.materialAppKey,
    this.navigatorKey,
    this.home,
    this.routes,
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorObservers,
    this.builder,
    this.title,
    this.onGenerateTitle,
    this.color,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales,
    this.debugShowMaterialGrid,
    this.showPerformanceOverlay,
    this.checkerboardRasterCacheImages,
    this.checkerboardOffscreenLayers,
    this.showSemanticsDebugger,
    this.debugShowCheckedModeBanner,
    this.shortcuts,
    this.actions,
  }) : super(key: materialAdmobBannerAppKey);

  @override
  State<StatefulWidget> createState() => _MaterialAdmobBannerAppState();
}

class _MaterialAdmobBannerAppState extends State<MaterialAdmobBannerApp> {
  @override
  Widget build(BuildContext context) {
    final app = Expanded(
      child: MaterialApp(
        key: widget.materialAppKey,
        navigatorKey: widget.navigatorKey,
        home: widget.home,
        routes: widget.routes ?? const <String, WidgetBuilder>{},
        initialRoute: widget.initialRoute,
        onGenerateRoute: widget.onGenerateRoute,
        onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
        onUnknownRoute: widget.onUnknownRoute,
        navigatorObservers:
            widget.navigatorObservers ?? const <NavigatorObserver>[],
        builder: widget.builder,
        title: widget.title ?? '',
        onGenerateTitle: widget.onGenerateTitle,
        color: widget.color,
        theme: widget.theme,
        darkTheme: widget.darkTheme,
        themeMode: widget.themeMode,
        locale: widget.locale,
        localizationsDelegates: widget.localizationsDelegates,
        localeListResolutionCallback: widget.localeListResolutionCallback,
        localeResolutionCallback: widget.localeResolutionCallback,
        supportedLocales:
            widget.supportedLocales ?? const <Locale>[Locale('en', 'US')],
        debugShowMaterialGrid: widget.debugShowMaterialGrid ?? false,
        showPerformanceOverlay: widget.showPerformanceOverlay ?? false,
        checkerboardRasterCacheImages:
            widget.checkerboardRasterCacheImages ?? false,
        checkerboardOffscreenLayers:
            widget.checkerboardOffscreenLayers ?? false,
        showSemanticsDebugger: widget.showSemanticsDebugger ?? false,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner ?? true,
        shortcuts: widget.shortcuts,
        actions: widget.actions,
      ),
    );

    final banner = Builder(builder: (BuildContext context) {
      final size = MediaQuery.of(context).size;
      final width = size.width;
      final heightPercentage = widget.bannerHeightPercentage ?? 0.05;
      final height =
          widget.bannerHeightFixed ?? max(size.height * heightPercentage, 50.0);
      return Container(
        width: width,
        height: height,
        child: AdmobBanner(
          adUnitId: widget.adUnitId,
          adSize: AdmobBannerSize.ADAPTIVE_BANNER(
            width: width.toInt(),
          ),
          listener: widget.listener,
          onBannerCreated: widget.onBannerCreated,
        ),
      );
    });


    return Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery(
        data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
        child: Container(
          color: widget.windowColor ?? widget.theme.primaryColor,
          child: SafeArea(
            top: !widget.bannerIsBottom,
            bottom: !widget.bannerIsBottom,
            child: Column(
              children: widget.bannerIsBottom
                  ? [
                      app,
                      banner,
                    ]
                  : [
                      banner,
                      app,
                    ],
            ),
          ),
        ),
      ),
    );
    return Container(
      color: widget.windowColor ?? widget.theme.primaryColor,
      child: MaterialApp(
        home: SafeArea(
          top: !widget.bannerIsBottom,
          child: Column(
            children: widget.bannerIsBottom
                ? [
                    app,
                    banner,
                  ]
                : [
                    banner,
                    app,
                  ],
          ),
        ),
      ),
    );

    return Container(
      color: widget.windowColor ?? widget.theme.primaryColor,
      child: Column(
        children: widget.bannerIsBottom
            ? [
                app,
                banner,
              ]
            : [
                banner,
                app,
              ],
      ),
    );

    return Column(
      children: [
        LayoutBuilder(builder: (context, boxConstraints) {
          return Container(
            color: Colors.red,
            width: boxConstraints.maxWidth,
            height: 200,
          );
        }),
      ],
    );
  }
}
