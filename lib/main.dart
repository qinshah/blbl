import 'package:flutter/material.dart';

import 'view/main_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFFF5F8F), // 主题色
        scaffoldBackgroundColor: const Color.fromRGBO(238, 238, 238, 1), // 背景色
      ), // 修改为粉色主题
      home: const MainPage(),
    );
  }
}
