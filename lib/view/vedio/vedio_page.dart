import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../model/video_recommend_model.dart';
import '../../service/net.dart';
import '../../service/nav.dart';

class VedioPage extends StatefulWidget {
  final String bvid;
  final String title;
  final String pic;

  const VedioPage({
    super.key,
    required this.bvid,
    required this.title,
    required this.pic,
  });

  @override
  State<VedioPage> createState() => _VedioPageState();
}

class _VedioPageState extends State<VedioPage> {
  late VideoPlayerController _controller;
  bool _showControls = false;
  Timer? _controlsTimer;
  final List<RecommendVideo> _recommendVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 初始化视频控制器
    // TODO 注意：这里使用了一个示例URL，实际应用中应该根据bvid获取真实的视频URL
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );
    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });

    // 获取推荐视频
    _fetchRecommendVideos();
  }

  Future<void> _fetchRecommendVideos() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // 使用API获取推荐视频
      final data = await Net.get(
        'https://api.bilibili.com/x/web-interface/archive/related?bvid=${widget.bvid}',
      );
      final response = VideoRecommendResponse.fromJson(data);
      setState(() {
        _recommendVideos.clear();
        _recommendVideos.addAll(response.data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('获取推荐视频失败: $e');
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // 取消之前的定时器
    _controlsTimer?.cancel();

    // 如果控制界面显示，设置5秒后自动隐藏
    if (_showControls) {
      _controlsTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _controlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频播放区域
            _buildVideoPlayer(),

            // 视频信息区域
            _buildVideoInfo(),

            // 分隔线
            const Divider(height: 1),

            // 推荐视频列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildRecommendList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.black,
        width: width,
        height: width * 9 / 16, // 16:9比例
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 视频播放器
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Image.network(
                    widget.pic,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),

            // 控制界面
            if (_showControls) ...[
              // 播放/暂停按钮
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),

              // 顶部控制栏
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.black45,
                  height: 40,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 底部控制栏
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.black45,
                  height: 40,
                  child: Row(
                    children: [
                      Text(
                        _controller.value.isInitialized
                            ? _formatDuration(
                                _controller.value.position.inSeconds)
                            : '0:00',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: _controller.value.isInitialized
                              ? _controller.value.position.inSeconds.toDouble()
                              : 0,
                          min: 0,
                          max: _controller.value.isInitialized
                              ? _controller.value.duration.inSeconds.toDouble()
                              : 0,
                          onChanged: (value) {
                            _controller
                                .seekTo(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      Text(
                        _controller.value.isInitialized
                            ? _formatDuration(
                                _controller.value.duration.inSeconds)
                            : '0:00',
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen, color: Colors.white),
                        onPressed: () {
                          // 全屏逻辑
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频标题
          Text(
            widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // 互动按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(Icons.thumb_up_outlined, '1.9万'),
              _buildActionButton(Icons.thumb_down_outlined, '不喜欢'),
              _buildActionButton(Icons.monetization_on_outlined, '2217'),
              _buildActionButton(Icons.star_outline, '4241'),
              _buildActionButton(Icons.share_outlined, '415'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecommendList() {
    return ListView.builder(
      itemCount: _recommendVideos.length,
      itemBuilder: (context, index) {
        final video = _recommendVideos[index];
        return _buildRecommendItem(video);
      },
    );
  }

  Widget _buildRecommendItem(RecommendVideo video) {
    return InkWell(
      onTap: () {
        context.push(VedioPage(
          bvid: video.bvid,
          title: video.title,
          pic: video.pic,
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频封面
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    video.pic,
                    width: 160,
                    height: 90,
                    fit: BoxFit.cover,
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
            const SizedBox(width: 12),

            // 视频信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.owner.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye_outlined,
                          size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 2),
                      Text(
                        '${video.stat.view}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.comment_outlined,
                          size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 2),
                      Text(
                        '${video.stat.danmaku}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
