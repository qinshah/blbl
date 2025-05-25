import 'package:flutter/material.dart';

extension NavExtension on BuildContext {
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));
  }

  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
}
