import 'package:flutter/material.dart';
import '../../provider/auth_provider.dart';
import '../login/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 获取AuthProvider实例
  final _authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: ListenableBuilder(
        listenable: _authProvider,
        builder: (context, child) {
          if (!_authProvider.isLoggedIn) {
            return _buildNotLoggedInView(context);
          }
          return _buildLoggedInView(context, _authProvider);
        },
      ),
    );
  }

  Widget _buildNotLoggedInView(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 顶部区域
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 头像
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '点击头像登录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 功能区域
          Expanded(
            child: _buildFunctionArea(context, null),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, AuthProvider authProvider) {
    final userInfo = authProvider.userInfo!;
    
    return SafeArea(
      child: Column(
        children: [
          // 顶部用户信息区域
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // 头像
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          userInfo['face'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // 用户信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                userInfo['uname'] ?? '用户',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (userInfo['vip']?['status'] == 1)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6699),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    '大会员',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'B币: ${userInfo['money'] ?? 0.0}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '硬币: ${userInfo['coins'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 设置按钮
                    IconButton(
                      onPressed: () {
                        _showLogoutDialog(context, authProvider);
                      },
                      icon: const Icon(Icons.settings),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 统计信息
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('动态', '${userInfo['dynamic'] ?? 38}'),
                    _buildStatItem('关注', '${userInfo['following'] ?? 139}'),
                    _buildStatItem('粉丝', '${userInfo['follower'] ?? 66}'),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 大会员信息
                if (userInfo['vip']?['status'] == 1)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6699), Color(0xFFFF9999)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '我的大会员',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '会员中心',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_outline,
                          color: Colors.pink.shade300,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '我的大会员',
                          style: TextStyle(
                            color: Colors.pink.shade300,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '热播内容看不停',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '会员中心',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // 功能区域
          Expanded(
            child: _buildFunctionArea(context, authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionArea(BuildContext context, AuthProvider? authProvider) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          // 功能图标区域
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFunctionIcon(Icons.download, '离线缓存'),
                    _buildFunctionIcon(Icons.history, '历史记录'),
                    _buildFunctionIcon(Icons.favorite, '我的收藏'),
                    _buildFunctionIcon(Icons.refresh, '稍后再看'),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 创作中心
          _buildSectionHeader('创作中心'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFunctionIcon(Icons.lightbulb_outline, '创作中心'),
                    _buildFunctionIcon(Icons.description, '稿件管理'),
                    _buildFunctionIcon(Icons.monetization_on, '创作激励'),
                    _buildFunctionIcon(Icons.flag, '有奖活动'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFunctionIcon(Icons.live_tv, '开播福利'),
                    _buildFunctionIcon(Icons.mic, '主播中心'),
                    _buildFunctionIcon(Icons.bar_chart, '直播数据'),
                    _buildFunctionIcon(Icons.event, '主播活动'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 推广横幅
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.school,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  '为2025高考生加油，赢好礼',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '立即参与 >',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 游戏中心
          _buildSectionHeader('游戏中心'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // image: const DecorationImage(
                    //   image: NetworkImage('https://via.placeholder.com/40'),
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '童年回忆来了！起航测试开启！',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '立即参与 >',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 游戏功能
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFunctionIcon(Icons.games, '我的游戏'),
                _buildFunctionIcon(Icons.card_giftcard, '游戏礼包'),
                _buildFunctionIcon(Icons.trending_up, '游戏排行榜'),
                _buildFunctionIcon(Icons.search, '找游戏'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 推荐服务
          _buildSectionHeader('推荐服务'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFunctionIcon(Icons.home, '首页'),
                _buildFunctionIcon(Icons.dynamic_feed, '动态'),
                _buildFunctionIcon(Icons.add_circle, ''),
                _buildFunctionIcon(Icons.shopping_bag, '会员购'),
                _buildFunctionIcon(Icons.person, '我的'),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (title == '创作中心')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '发布',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFunctionIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // TODO: 我的页面按钮对应功能
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}