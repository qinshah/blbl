import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../model/video_recommend_model.dart';
import '../../service/net.dart';
import '../../service/nav.dart';
import '../../service/video_service.dart';

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
  bool _isVideoLoading = true;
  String? _errorMessage;
  int? _cid;
  bool _isVideoMinimized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初始化一个空的控制器，稍后会更新
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );
    
    // 获取视频流URL并初始化播放器
    _initVideoPlayer();
    
    // 获取推荐视频
    _fetchRecommendVideos();

    // 监听滚动事件，用于控制视频最小化
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // 当滚动位置超过一定值时，将视频最小化
    // TODO 小播放器的关闭逻辑
    if (_scrollController.offset > 200 && !_isVideoMinimized) {
      setState(() {
        _isVideoMinimized = true;
      });
    } else if (_scrollController.offset <= 200 && _isVideoMinimized) {
      setState(() {
        _isVideoMinimized = false;
      });
    }
  }

  Future<void> _initVideoPlayer() async {
    try {
      setState(() {
        _isVideoLoading = true;
        _errorMessage = null;
      });

      // 首先获取视频信息，包括cid
      final videoInfoData = await VideoService.getVideoInfo(widget.bvid);
      _cid = VideoService.getCidFromVideoInfo(videoInfoData);

      if (_cid == null) {
        setState(() {
          _isVideoLoading = false;
          _errorMessage = '无法获取视频信息，请稍后再试';
        });
        return;
      }

      // 获取视频流URL
      final data = await VideoService.getVideoStreamUrl(
        bvid: widget.bvid,
        cid: _cid!,
      );

      // 解析视频URL
      final videoUrl = VideoService.parseVideoUrl(data);

      if (videoUrl == null) {
        setState(() {
          _isVideoLoading = false;
          _errorMessage = '无法获取视频流，请稍后再试';
        });
        return;
      }

      print('获取到视频URL: $videoUrl');

      // 释放旧的控制器
      await _controller.dispose();

      // 创建新的控制器
      _controller = VideoPlayerController.network(
        videoUrl,
        httpHeaders: {
          'Referer': 'https://www.bilibili.com',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      // 初始化并播放
      await _controller.initialize();
      await _controller.play();

      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _errorMessage = '视频加载失败: $e';
        });
      }
      print('视频加载失败: $e');
    }
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
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 主内容区域
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 视频播放区域（可折叠）
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: true,
                  expandedHeight: MediaQuery.of(context).size.width * 9 / 16,
                  collapsedHeight: 56,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildVideoPlayer(),
                  ),
                  title: _isVideoMinimized ? Text(
                    widget.title,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ) : null,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: _isVideoMinimized ? [
                    // 最小化时的播放/暂停按钮
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                    ),
                  ] : null,
                ),

                // 视频信息区域
                SliverToBoxAdapter(
                  child: _buildVideoInfo(),
                ),

                // 分隔线
                const SliverToBoxAdapter(
                  child: Divider(height: 1),
                ),

                // 推荐视频列表
                _isLoading
                    ? const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final video = _recommendVideos[index];
                            return _buildRecommendItem(video);
                          },
                          childCount: _recommendVideos.length,
                        ),
                      ),
              ],
            ),

            // 最小化时的视频播放器（固定在右下角）
            if (_isVideoMinimized && _controller.value.isInitialized && _errorMessage == null)
              Positioned(
                right: 16,
                bottom: 16,
                child: GestureDetector(
                  onTap: () {
                    // 点击小窗口时，滚动回顶部展开视频
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 小窗口中的视频
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: VideoPlayer(_controller),
                        ),
                        // 关闭按钮
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller.pause();
                                _isVideoMinimized = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
            if (_isVideoLoading) 
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else if (_errorMessage != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initVideoPlayer,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              )
            else if (_controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            else
              Image.network(
                widget.pic,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

            // 控制界面
            if (_showControls && _controller.value.isInitialized && _errorMessage == null && !_isVideoMinimized) ...[              
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
