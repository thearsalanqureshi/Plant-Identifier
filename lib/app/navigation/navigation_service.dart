import 'package:flutter/material.dart';

class NavigationService {
static  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


 static BuildContext? get currentContext => navigatorKey.currentContext;

  Future<void> pushNamed(String routeName, {Object? arguments}) async {
    await navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  void pop() {
    navigatorKey.currentState!.pop();
  }

  Future<void> pushReplacementNamed(String routeName, {Object? arguments}) async {
    await navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }
}