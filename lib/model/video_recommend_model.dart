import 'dart:convert';

class VideoRecommendResponse {
  final int code;
  final String message;
  final int ttl;
  final List<RecommendVideo> data;

  VideoRecommendResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.data,
  });

  factory VideoRecommendResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return VideoRecommendResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      ttl: json['ttl'] ?? 0,
      data: dataList.map((item) => RecommendVideo.fromJson(item)).toList(),
    );
  }

  static VideoRecommendResponse fromJsonString(String jsonString) {
    return VideoRecommendResponse.fromJson(json.decode(jsonString));
  }
}

class RecommendVideo {
  final String bvid;
  final int cid;
  final String title;
  final String description;
  final String pic;
  final int duration;
  final Owner owner;
  final Stat stat;
  final String pubdate;

  RecommendVideo({
    required this.bvid,
    required this.cid,
    required this.title,
    required this.description,
    required this.pic,
    required this.duration,
    required this.owner,
    required this.stat,
    required this.pubdate,
  });

  factory RecommendVideo.fromJson(Map<String, dynamic> json) {
    return RecommendVideo(
      bvid: json['bvid'] ?? '',
      cid: json['cid'] ?? 0,
      title: json['title'] ?? '',
      description: json['desc'] ?? '',
      pic: json['pic'] ?? '',
      duration: json['duration'] ?? 0,
      owner: Owner.fromJson(json['owner'] ?? {}),
      stat: Stat.fromJson(json['stat'] ?? {}),
      pubdate: json['pubdate'].toString(),
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

class Stat {
  final int view;
  final int danmaku;
  final int reply;
  final int favorite;
  final int coin;
  final int share;
  final int like;

  Stat({
    required this.view,
    required this.danmaku,
    required this.reply,
    required this.favorite,
    required this.coin,
    required this.share,
    required this.like,
  });

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      view: json['view'] ?? 0,
      danmaku: json['danmaku'] ?? 0,
      reply: json['reply'] ?? 0,
      favorite: json['favorite'] ?? 0,
      coin: json['coin'] ?? 0,
      share: json['share'] ?? 0,
      like: json['like'] ?? 0,
    );
  }
}