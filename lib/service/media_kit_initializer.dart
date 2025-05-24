import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

/// MediaKit初始化服务
/// 
/// 负责在应用启动时初始化MediaKit库
class MediaKitInitializer {
  /// 是否已初始化
  static bool _isInitialized = false;

  /// 初始化MediaKit
  /// 
  /// 应在应用启动时调用此方法
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 仅在Windows平台初始化MediaKit
      if (Platform.isWindows) {
        // 初始化MediaKit
        MediaKit.ensureInitialized();
        debugPrint('MediaKit初始化成功');
      } else {
        debugPrint('非Windows平台，跳过MediaKit初始化');
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('MediaKit初始化失败: $e');
      rethrow;
    }
  }

  /// 判断当前平台是否为Windows
  static bool get isWindows => Platform.isWindows;

  /// 判断MediaKit是否已初始化
  static bool get isInitialized => _isInitialized;
}