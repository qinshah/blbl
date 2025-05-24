import 'package:flutter/material.dart';
import '../../model/video_model.dart';
import '../../service/net.dart';
import '../../service/nav.dart';
import '../vedio/vedio_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
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
      final data = await Net.get(
          'https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd');
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
    return Container(
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
    );
  }

  Widget _buildTabBar() {
    final tabs = ['推荐', '热门', '动画', '影视', '新征程'];
    return Container(
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
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.9,
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
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          context.push(VedioPage(
            bvid: video.bvid,
            title: video.title,
            pic: video.pic,
          ));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频封面
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
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
                Positioned(
                  right: 5,
                  bottom: 5,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(video.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            // 视频标题
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            // 视频数据
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined,
                      size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 2),
                  Text(
                    _formatCount(video.stat.view),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.comment_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 2),
                  Text(
                    _formatCount(video.stat.danmaku),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
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
