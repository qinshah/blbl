import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// Windows平台使用media_kit
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// 通用播放器控制器
class UniversalPlayerController {
  final String videoUrl;
  final Map<String, String> headers;

  // VideoPlayer控制器
  VideoPlayerController? _videoController;

  // MediaKit控制器
  Player? _mediaKitPlayer;
  VideoController? _mediaKitVideoController;

  // 播放器状态
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  Size _videoSize = const Size(16, 9);

  UniversalPlayerController({
    required this.videoUrl,
    required this.headers,
  });

  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  Size get size => _videoSize;
  String get dataSource => videoUrl;
  Map<String, String>? get httpHeaders => headers;

  Future<void> initialize() async {
    if (Platform.isWindows) {
      // Windows平台使用MediaKit
      _mediaKitPlayer = Player();
      _mediaKitVideoController = VideoController(_mediaKitPlayer!);

      // 打开媒体，并设置HTTP请求头
      await _mediaKitPlayer!.open(Media(videoUrl, httpHeaders: headers));

      // 监听状态变化
      _mediaKitPlayer!.stream.playing.listen((playing) {
        _isPlaying = playing;
      });

      _mediaKitPlayer!.stream.position.listen((position) {
        _position = position;
      });

      _mediaKitPlayer!.stream.duration.listen((duration) {
        _duration = duration;
      });

      _mediaKitPlayer!.stream.volume.listen((volume) {
        _volume = volume / 100; // MediaKit音量范围是0-100
      });

      // 设置初始化状态
      _isInitialized = true;
      _videoSize = const Size(16, 9); // MediaKit暂不支持获取视频尺寸
    } else {
      // 其他平台使用video_player
      _videoController = VideoPlayerController.network(
        videoUrl,
        httpHeaders: headers,
      );

      await _videoController!.initialize();

      // 设置初始化状态
      _isInitialized = true;
      _isPlaying = _videoController!.value.isPlaying;
      _position = _videoController!.value.position;
      _duration = _videoController!.value.duration;
      _volume = _videoController!.value.volume;
      _videoSize = _videoController!.value.size;

      // 添加监听器
      _videoController!.addListener(() {
        _isPlaying = _videoController!.value.isPlaying;
        _position = _videoController!.value.position;
        _duration = _videoController!.value.duration;
        _volume = _videoController!.value.volume;
        _videoSize = _videoController!.value.size;
      });
    }
  }

  Future<void> play() async {
    if (Platform.isWindows) {
      await _mediaKitPlayer?.play();
    } else {
      await _videoController?.play();
    }
  }

  Future<void> pause() async {
    if (Platform.isWindows) {
      await _mediaKitPlayer?.pause();
    } else {
      await _videoController?.pause();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (Platform.isWindows) {
      await _mediaKitPlayer?.seek(position);
    } else {
      await _videoController?.seekTo(position);
    }
  }

  Future<void> setVolume(double volume) async {
    if (Platform.isWindows) {
      await _mediaKitPlayer?.setVolume(volume * 100); // MediaKit音量范围是0-100
    } else {
      await _videoController?.setVolume(volume);
    }
  }

  Future<void> dispose() async {
    if (Platform.isWindows) {
      await _mediaKitPlayer?.dispose();
    } else {
      await _videoController?.dispose();
    }
  }

  VideoController? get mediaKitVideoController => _mediaKitVideoController;
  VideoPlayerController? get videoPlayerController => _videoController;
}

// 在Windows平台使用media_kit
// 在其他平台使用video_player

/// 跨平台视频播放器服务
///
/// 在Windows平台使用media_kit
/// 在其他平台使用video_player
class PlayerService {
  /// 判断当前平台是否为Windows
  static bool get isWindows => Platform.isWindows;

  /// 创建视频播放器控制器
  ///
  /// [videoUrl] 视频URL
  /// [headers] HTTP请求头
  static UniversalPlayerController createController({
    required String videoUrl,
    required Map<String, String> headers,
  }) {
    return UniversalPlayerController(
      videoUrl: videoUrl,
      headers: headers,
    );
  }
}
