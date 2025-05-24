import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// Windows平台使用media_kit
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// 通用视频播放器组件
/// 
/// 根据平台自动选择合适的播放器实现
class UniversalPlayer extends StatefulWidget {
  /// 视频URL
  final String videoUrl;
  
  /// HTTP请求头
  final Map<String, String> headers;
  
  /// 播放器宽度
  final double width;
  
  /// 播放器高度
  final double height;
  
  /// 是否自动播放
  final bool autoPlay;
  
  /// 是否循环播放
  final bool loop;
  
  /// 初始音量
  final double volume;
  
  /// 播放状态变化回调
  final void Function(bool isPlaying)? onPlayingChanged;
  
  /// 进度变化回调
  final void Function(Duration position, Duration duration)? onPositionChanged;
  
  /// 初始化完成回调
  final void Function()? onInitialized;
  
  /// 错误回调
  final void Function(String error)? onError;

  const UniversalPlayer({
    super.key,
    required this.videoUrl,
    required this.headers,
    required this.width,
    required this.height,
    this.autoPlay = true,
    this.loop = false,
    this.volume = 1.0,
    this.onPlayingChanged,
    this.onPositionChanged,
    this.onInitialized,
    this.onError,
  });

  @override
  State<UniversalPlayer> createState() => _UniversalPlayerState();
}

class _UniversalPlayerState extends State<UniversalPlayer> {
  // VideoPlayer相关变量
  VideoPlayerController? _videoController;
  bool _isVideoPlayerInitialized = false;
  
  // MediaKit相关变量
  Player? _mediaKitPlayer;
  VideoController? _mediaKitVideoController;
  bool _isMediaKitInitialized = false;
  
  // 通用状态变量
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  // 判断当前平台是否为Windows
  bool get _isWindows => Platform.isWindows;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    // 释放资源
    if (_isWindows) {
      _mediaKitPlayer?.dispose();
    } else {
      _videoController?.dispose();
    }
    super.dispose();
  }

  // 初始化播放器
  Future<void> _initPlayer() async {
    try {
      if (_isWindows) {
        await _initMediaKitPlayer();
      } else {
        await _initVideoPlayer();
      }
    } catch (e) {
      _setError('初始化播放器失败: $e');
    }
  }

  // 初始化VideoPlayer
  Future<void> _initVideoPlayer() async {
    try {
      // 创建控制器
      _videoController = VideoPlayerController.network(
        widget.videoUrl,
        httpHeaders: widget.headers,
      );

      // 初始化
      await _videoController!.initialize();
      
      // 设置音量和循环
      await _videoController!.setVolume(widget.volume);
      await _videoController!.setLooping(widget.loop);
      
      // 添加监听器
      _videoController!.addListener(_videoPlayerListener);
      
      // 自动播放
      if (widget.autoPlay) {
        await _videoController!.play();
      }
      
      if (mounted) {
        setState(() {
          _isVideoPlayerInitialized = true;
          _isInitialized = true;
          _isPlaying = _videoController!.value.isPlaying;
        });
        
        // 回调
        widget.onInitialized?.call();
      }
    } catch (e) {
      _setError('初始化VideoPlayer失败: $e');
    }
  }

  // VideoPlayer监听器
  void _videoPlayerListener() {
    if (_videoController == null || !mounted) return;
    
    final isPlaying = _videoController!.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
      widget.onPlayingChanged?.call(isPlaying);
    }
    
    widget.onPositionChanged?.call(
      _videoController!.value.position,
      _videoController!.value.duration,
    );
  }

  // 初始化MediaKit播放器
  Future<void> _initMediaKitPlayer() async {
    try {
      // 创建播放器实例
      _mediaKitPlayer = Player();
      _mediaKitVideoController = VideoController(_mediaKitPlayer!);
      
      // if (widget.headers.isNotEmpty) {
      //   await _mediaKitPlayer!.setProperty(
      //     'http-header-fields',
      //     widget.headers.entries.map((e) => '${e.key}: ${e.value}').toList(),
      //   );
      // }
      
      // 打开媒体
      await _mediaKitPlayer!.open(Media(widget.videoUrl));
      
      // 设置音量和循环
      await _mediaKitPlayer!.setVolume(widget.volume * 100); // MediaKit音量范围是0-100
      await _mediaKitPlayer!.setPlaylistMode(widget.loop ? PlaylistMode.loop : PlaylistMode.single);
      
      // 监听播放状态
      _mediaKitPlayer!.stream.playing.listen((playing) {
        if (mounted && playing != _isPlaying) {
          setState(() {
            _isPlaying = playing;
          });
          widget.onPlayingChanged?.call(playing);
        }
      });
      
      // 监听位置变化
      _mediaKitPlayer!.stream.position.listen((position) {
        if (mounted) {
          widget.onPositionChanged?.call(
            position,
            _mediaKitPlayer!.state.duration,
          );
        }
      });
      
      // 自动播放
      if (widget.autoPlay) {
        await _mediaKitPlayer!.play();
      }
      
      if (mounted) {
        setState(() {
          _isMediaKitInitialized = true;
          _isInitialized = true;
          _isPlaying = _mediaKitPlayer!.state.playing;
        });
        
        // 回调
        widget.onInitialized?.call();
      }
    } catch (e) {
      _setError('初始化MediaKit失败: $e');
    }
  }

  // 设置错误状态
  void _setError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
      });
      widget.onError?.call(message);
    }
  }

  // 播放
  Future<void> play() async {
    if (_isWindows) {
      await _mediaKitPlayer?.play();
    } else {
      await _videoController?.play();
    }
  }

  // 暂停
  Future<void> pause() async {
    if (_isWindows) {
      await _mediaKitPlayer?.pause();
    } else {
      await _videoController?.pause();
    }
  }

  // 跳转到指定位置
  Future<void> seekTo(Duration position) async {
    if (_isWindows) {
      await _mediaKitPlayer?.seek(position);
    } else {
      await _videoController?.seekTo(position);
    }
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    if (_isWindows) {
      await _mediaKitPlayer?.setVolume(volume * 100); // MediaKit音量范围是0-100
    } else {
      await _videoController?.setVolume(volume);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 显示错误
    if (_hasError) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initPlayer,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    
    // 显示加载中
    if (!_isInitialized) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    
    // 根据平台选择播放器实现
    if (_isWindows) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Video(
          controller: _mediaKitVideoController!,
          controls: NoVideoControls,
          fill: Colors.black,
        ),
      );
    } else {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    }
  }
}