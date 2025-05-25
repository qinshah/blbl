import 'package:flutter/material.dart';
import '../../model/video_model.dart';
import '../../service/net_service.dart';
import '../../service/nav_extension.dart';
import '../../provider/auth_provider.dart';
import '../vedio/vedio_page.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // 获取AuthProvider实例
  final _authProvider = AuthProvider();
  final _videoList = <VideoItem>[];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendVideos();
  }

  Future<void> _fetchRecommendVideos() async {
    try {
      setState(() {
        _videoList.clear();
        _isLoading = true;
      });
      //  TODO 不生效 添加时间戳参数，尝试获取不同的推荐列表
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final data = await Net.get(
          'https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd?_=$timestamp');
      final response = VideoListResponse.fromJson(data);
      setState(() {
        _videoList.addAll(response.data.items);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('获取推荐视频失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: _buildSearchBar(),
        actions: [
          IconButton(
              icon: const Icon(Icons.videogame_asset_outlined),
              onPressed: () {}),
          IconButton(icon: const Icon(Icons.mail_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchRecommendVideos,
                    child: _buildVideoGrid(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ListenableBuilder(
      listenable: _authProvider,
      builder: (context, child) {
        return Row(
          children: [
            // 登录按钮
            GestureDetector(
              onTap: () {
                if (_authProvider.isLoggedIn) {
                  // 已登录，显示用户信息或跳转到个人页面
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已登录')),
                  );
                } else {
                  // 未登录，跳转到登录页面
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                }
              },
              child: Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _authProvider.isLoggedIn
                      ? Colors.white
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child:
                    _authProvider.isLoggedIn && _authProvider.userInfo != null
                        ? ClipOval(
                            child: Image.network(
                              _authProvider.userInfo!['face'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 20,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 20,
                          ),
              ),
            ),
            // 搜索框
            Expanded(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '灵笼第二季',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar() {
    final tabs = ['推荐', '热门', '动画', '影视', '新征程'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length + 1, // +1 for the menu button
        itemBuilder: (context, index) {
          if (index == tabs.length) {
            return IconButton(icon: const Icon(Icons.menu), onPressed: () {});
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: index == 0
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black,
                  fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(6),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.8,
      ),
      itemCount: _videoList.length,
      itemBuilder: (context, index) {
        final video = _videoList[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(VideoItem video) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          context.push(
              VedioPage(bvid: video.bvid, title: video.title, pic: video.pic));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频封面
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.4,
                  child: Image.network(
                    video.pic,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.error)),
                      );
                    },
                  ),
                ),
                // 视频数据
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 14, 6, 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4)
                        ],
                      ),
                    ),
                    child: Row(children: [
                      // 播放量
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        _formatCount(video.stat.view),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      // 弹幕量
                      const Icon(Icons.comment_outlined,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        _formatCount(video.stat.danmaku),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          _formatDuration(video.duration),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      )
                    ]),
                  ),
                ),
              ],
            ),
            // 视频标题
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            // 视频作者
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  // TODO 如果视频是竖屏，显示竖屏标签
                  Expanded(
                    child: Text(
                      video.owner.name,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      // TODO 显示更多选项
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }
}
