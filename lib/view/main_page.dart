import 'package:flutter/material.dart';

import '../service/net.dart';
import 'home/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _navItems = [
    NavItem(title: '首页', icon: Icons.home, page: HomePage()),
    NavItem(title: '动态', icon: Icons.search, page: HomePage()),
    NavItem(title: '会员购', icon: Icons.message, page: HomePage()),
    NavItem(title: '我的', icon: Icons.person, page: HomePage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IconButton(
        onPressed: () async {
          final data = await Net.get(
              'https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd');
          print(data);
        },
        icon: Icon(Icons.abc),
      ),
      // bottomNavigationBar: ,
    );
  }
}

class NavItem {
  final String title;
  final IconData icon;
  final Widget page;

  NavItem({required this.title, required this.icon, required this.page});
}
