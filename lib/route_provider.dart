import 'package:flutter/material.dart';

class RouteProvider with ChangeNotifier {
  String _initialRoute;

  RouteProvider(this._initialRoute);

  String get initialRoute => _initialRoute;

  set initialRoute(String route) {
    _initialRoute = route;
    notifyListeners();
  }
}