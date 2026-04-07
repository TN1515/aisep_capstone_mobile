import 'package:flutter/material.dart';

class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?>? pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?>? push<T>(Route<T> route) {
    return navigatorKey.currentState?.push<T>(route);
  }

  static Future<T?>? pushReplacement<T, TO>(Route<T> route) {
    return navigatorKey.currentState?.pushReplacement<T, TO>(route);
  }

  static void pop<T>([T? result]) {
    return navigatorKey.currentState?.pop<T>(result);
  }

  static void popToRoot() {
    return navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  static Future<T?>? pushAndRemoveUntil<T>(Route<T> route) {
    return navigatorKey.currentState?.pushAndRemoveUntil<T>(route, (route) => false);
  }
}
