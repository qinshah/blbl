import 'package:flutter/material.dart';

import 'home/home_page.dart';
import 'profile/profile_page.dart';
import 'dynamic/dynamic_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final _navItems = [
    NavItem(title: '首页', icon: Icons.home, page: const HomePage()),
    NavItem(
        title: '动态', icon: Icons.videocam_outlined, page: const DynamicPage()),
    NavItem(
        title: '',
        icon: Icons.add_circle_outline,
        page: const Center(child: Text('发布'))),
    NavItem(
        title: '会员购',
        icon: Icons.shopping_bag_outlined,
        page: const Center(child: Text('会员购'))),
    NavItem(title: '我的', icon: Icons.person_outline, page: const ProfilePage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // TODO 背景透明
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: (index) {
          // TODO 底部导航栏刷新内容
          if (index != 2) {
            // 中间的发布按钮不切换页面
            setState(() {
              _currentIndex = index;
            });
          } else {
            // 处理发布按钮点击
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('发布功能暂未实现')),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.title,
          );
        }).toList(),
      ),
    );
  }
}

class NavItem {
  final String title;
  final IconData icon;
  final Widget page;

  NavItem({required this.title, required this.icon, required this.page});
}
