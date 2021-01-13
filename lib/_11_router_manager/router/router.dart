import 'package:flutter/material.dart';

import '../main.dart';
import '../about.dart';
import '../detail.dart';
import '../unknown.dart';

class HYRouter {
  static final Map<String, WidgetBuilder> routes = {
    HYHomePage.routeName: (ctx) => HYHomePage(),
    HYAboutPage.routeName: (ctx) => HYAboutPage()
  };

  static final String initialRoute = HYHomePage.routeName;

  static final RouteFactory generateRoute = (settings) {
    if (settings.name == HYDetailPage.routeName) {
      return MaterialPageRoute(
          builder: (ctx) {
            return HYDetailPage(settings.arguments);
          }
      );
    }
    return null;
  };

  static final RouteFactory unknownRoute = (settings) {
    return MaterialPageRoute(
        builder: (ctx) {
          return HYUnknownPage();
        }
    );
  };
}