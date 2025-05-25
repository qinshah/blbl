import 'package:flutter/material.dart';
import 'view/main_page.dart';

import 'provider/auth_provider.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化AuthProvider
  await AuthProvider().init();
  
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
      ),
      home: const MainPage(),
    );
  }
}
