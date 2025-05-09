import 'package:flutter/material.dart';

extension NavigationExtension on BuildContext {
  void navigateTo(Widget screen) {
    Navigator.of(this).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<T?> pushPage<T>(Widget screen) {
    return Navigator.of(this)
        .push<T>(MaterialPageRoute(builder: (_) => screen));
  }

  void replaceWith(Widget screen) {
    Navigator.of(this)
        .pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }
  void navigateBack<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

}