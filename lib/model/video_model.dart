import 'dart:convert';

class VideoListResponse {
  final int code;
  final String message;
  final int ttl;
  final VideoData data;

  VideoListResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.data,
  });

  factory VideoListResponse.fromJson(Map<String, dynamic> json) {
    return VideoListResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      ttl: json['ttl'] ?? 0,
      data: VideoData.fromJson(json['data'] ?? {}),
    );
  }

  static VideoListResponse fromJsonString(String jsonString) {
    return VideoListResponse.fromJson(json.decode(jsonString));
  }
}

class VideoData {
  final List<VideoItem> items;

  VideoData({required this.items});

  factory VideoData.fromJson(Map<String, dynamic> json) {
    final itemList = json['item'] as List<dynamic>? ?? [];
    return VideoData(
      items: itemList.map((item) => VideoItem.fromJson(item)).toList(),
    );
  }
}

class VideoItem {
  final int id;
  final String bvid;
  final int cid;
  final String goto;
  final String uri;
  final String pic;
  final String pic43;
  final String title;
  final int duration;
  final int pubdate;
  final Owner owner;
  final VideoStat stat;

  VideoItem({
    required this.id,
    required this.bvid,
    required this.cid,
    required this.goto,
    required this.uri,
    required this.pic,
    required this.pic43,
    required this.title,
    required this.duration,
    required this.pubdate,
    required this.owner,
    required this.stat,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] ?? 0,
      bvid: json['bvid'] ?? '',
      cid: json['cid'] ?? 0,
      goto: json['goto'] ?? '',
      uri: json['uri'] ?? '',
      pic: json['pic'] ?? '',
      pic43: json['pic_4_3'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? 0,
      pubdate: json['pubdate'] ?? 0,
      owner: Owner.fromJson(json['owner'] ?? {}),
      stat: VideoStat.fromJson(json['stat'] ?? {}),
    );
  }
}

class Owner {
  final int mid;
  final String name;
  final String face;

  Owner({
    required this.mid,
    required this.name,
    required this.face,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      mid: json['mid'] ?? 0,
      name: json['name'] ?? '',
      face: json['face'] ?? '',
    );
  }
}

class VideoStat {
  final int view;
  final int like;
  final int danmaku;

  VideoStat({
    required this.view,
    required this.like,
    required this.danmaku,
  });

  factory VideoStat.fromJson(Map<String, dynamic> json) {
    return VideoStat(
      view: json['view'] ?? 0,
      like: json['like'] ?? 0,
      danmaku: json['danmaku'] ?? 0,
    );
  }
}