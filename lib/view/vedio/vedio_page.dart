import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../model/video_recommend_model.dart';
import '../../service/net_service.dart';
import '../../service/nav_extension.dart';
import '../../service/video_service.dart';
import './blbl_player.dart'; // 引入新的播放器组件


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
  final List<RecommendVideo> _recommendVideos = [];
  bool _isLoading = true;
  bool _isVideoLoading = true;
  String? _errorMessage;
  int? _cid;
  late double _deviceWidth = MediaQuery.of(context).size.width;
  final ScrollController _scrollController = ScrollController();

  double _hWRatio = 9 / 16; // 默认宽高比

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(''); // 初始化一个空的controller
    _initVideoPlayer();
    _fetchRecommendVideos();
  }

  Future<void> _initVideoPlayer() async {
    setState(() {
      _isVideoLoading = true;
      _errorMessage = null;
    });
    try {
      final videoInfoData = await VideoService.getVideoInfo(widget.bvid);
      _cid = VideoService.getCidFromVideoInfo(videoInfoData);
      if (_cid == null) {
        setState(() {
          _isVideoLoading = false;
          _errorMessage = '无法获取视频信息，请稍后再试';
        });
        return;
      }
      final data = await VideoService.getVideoStreamUrl(
        bvid: widget.bvid,
        cid: _cid!,
        fnval: 1,
      );
      final urlMap = VideoService.parseVideoUrl(data);
      if (urlMap == null || urlMap['videoUrl'] == null) {
        setState(() {
          _isVideoLoading = false;
          _errorMessage = '无法获取视频流，请稍后再试';
        });
        return;
      }
      final videoUrl = urlMap['videoUrl']!;
      print('获取到视频URL: $videoUrl');

      // 释放旧的控制器（如果存在且已初始化）
      if (_controller.value.isInitialized) {
        await _controller.dispose();
      }

      _controller = VideoPlayerController.network(
        videoUrl,
        httpHeaders: {
          'Referer': 'https://www.bilibili.com',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );
      await _controller.initialize();
      await _controller.play();
      _controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
      if (mounted) {
        setState(() {
          final videoSize = _controller.value.size;
          if (videoSize.width > 0 && videoSize.height > 0) {
            if (videoSize.width > videoSize.height) {
              _hWRatio = videoSize.height / videoSize.width;
              if (_hWRatio < (9/16 - 0.1) || _hWRatio > (9/16 + 0.1)) {
                   _hWRatio = 9/16;
              }
            } else {
              _hWRatio = 1.0; 
            }
          } else {
            _hWRatio = 9/16; // Fallback if size is invalid
          }
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
  // 添加 _formatDuration 方法，供推荐列表使用
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: true,
                  expandedHeight: _isVideoLoading || _errorMessage != null 
                                    ? _deviceWidth * (9/16) 
                                    : _deviceWidth * _hWRatio,
                  collapsedHeight: 56,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildVideoPlayerContainer(), // 使用新的构建方法
                  ),
                  title: ListenableBuilder(
                    listenable: _scrollController,
                    builder: (context, child) {
                      final isScrolled = _scrollController.hasClients &&
                          _scrollController.offset > 0;
                      return isScrolled
                          ? GestureDetector(
                              onTap: () {
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                  leading: ListenableBuilder(
                    listenable: _scrollController,
                    builder: (context, child) {
                      final isScrolled = _scrollController.hasClients &&
                          _scrollController.offset > 0;
                      return isScrolled
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ),
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
          ],
        ),
      ),
    );
  }

  // 新的 _buildVideoPlayerContainer 方法，使用 BlblPlayer
  Widget _buildVideoPlayerContainer() {
    if (_isVideoLoading) {
      return Container(
        color: Colors.black,
        width: _deviceWidth,
        height: _deviceWidth * (9/16), // 保持加载时的默认高度
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_errorMessage != null) {
      return Container(
        color: Colors.black,
        width: _deviceWidth,
        height: _deviceWidth * (9/16), // 保持错误时的默认高度
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
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
      );
    }
    // 确保 _controller 已经初始化并且有有效的宽高比
    // BlblPlayer 内部会处理 controller 未初始化的情况，但这里可以提前返回占位图
    if (!_controller.value.isInitialized) {
        return Container(
            color: Colors.black,
            width: _deviceWidth,
            height: _deviceWidth * _hWRatio,
            child: widget.pic.isNotEmpty 
                ? Image.network(widget.pic, fit: BoxFit.cover)
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
        );
    }

    return BlblPlayer(
      controller: _controller,
      pic: widget.pic,
      isfullScreen: false, // 在主页面，不是全屏
      // height 和 width 将由 BlblPlayer 内部根据 fullScreen 和 aspectRatio 决定
      // 但外部容器 SliverAppBar 的 expandedHeight 已经设定了高度
    );
  }

  // 移除旧的 _buildVideoPlayer 方法
  /*
  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _toggleControls, // _toggleControls 将被移除
      child: Container(
        color: Colors.black,
        width: _deviceWidth,
        height: _deviceWidth * _hWRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 视频播放器
            if (_isVideoLoading)
              const Center(
                  child: CircularProgressIndicator(color: Colors.white))
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
            // _showControls 和相关逻辑将被移除
            // ... (旧的控制UI代码)
          ],
        ),
      ),
    );
  }
  */

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
        // 确保在跳转前暂停当前视频
        if (_controller.value.isPlaying) {
          _controller.pause();
        }
        context
            .push(VedioPage(
          bvid: video.bvid,
          title: video.title,
          pic: video.pic,
        ))
            .then((value) {
          // 从推荐视频返回后，如果当前页面还在，并且视频已初始化，则尝试播放
          if (mounted && _controller.value.isInitialized) {
            _controller.play();
          }
        });
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
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${video.owner.name} · ${_formatDuration(video.duration)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
