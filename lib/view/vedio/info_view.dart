import 'package:blbl/service/nav_extension.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../model/video_recommend_model.dart';
import '../../service/net_service.dart';
import 'vedio_page.dart';

class InfoView extends StatefulWidget {
  const InfoView(
      {super.key, required this.bvid, required this.controller});

  final String bvid;

  final VideoPlayerController controller;

  @override
  State<InfoView> createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  List<RecommendVideo>? _videos;

  @override
  void initState() {
    _getVideos();
    super.initState();
  }

  void _getVideos() async {
    final data = await Net.resDataByGet(
      'https://api.bilibili.com/x/web-interface/archive/related?bvid=${widget.bvid}',
    );
    setState(() {
      _videos = VideoRecommendResponse.fromJson(data).data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_videos == null) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildRecommendItem(_videos![index]),
        childCount: _videos!.length,
      ),
    );
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

  Widget _buildRecommendItem(RecommendVideo video) {
    return InkWell(
      onTap: () {
        // TODO: 控制器有可能没有初始化
        widget.controller.pause();
        context
            .push(VedioPage(
          bvid: video.bvid,
          title: video.title,
          pic: video.pic,
        ))
            .then((value) {
          if (mounted) {
            widget.controller.play();
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
