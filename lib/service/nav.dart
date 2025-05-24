import 'package:flutter/material.dart';

extension NavExtension on BuildContext {
  static void push(Widget page) {
    Navigator.of(this).push(MaterialPageRoute(builder: (_) => page));
  }
}
