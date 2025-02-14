import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class ScreenTimeRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  // Map to store the entry time for each route
  final Map<PageRoute<dynamic>, DateTime> _routeEnterTime = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if (route is PageRoute) {
      // Log the screen view using logScreenView.
      // Make sure that route.settings.name is set.
      FirebaseAnalytics.instance.logScreenView(
        screenName: route.settings.name,
        screenClass: route.settings.name, // Use a custom screen class name if needed.
      );

      // Record the time the screen was entered.
      _routeEnterTime[route] = DateTime.now();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    if (route is PageRoute && _routeEnterTime.containsKey(route)) {
      // Calculate the duration the screen was visible.
      final duration = DateTime.now().difference(_routeEnterTime[route]!);

      // Log the duration as a custom event.
      FirebaseAnalytics.instance.logEvent(
        name: 'screen_duration',
        parameters: {
          'screen': route.settings.name,
          'duration_in_seconds': duration.inSeconds,
        },
      );

      // Remove the recorded time.
      _routeEnterTime.remove(route);
    }
  }

  // You may also override didReplace if you want to handle route replacements.
}
