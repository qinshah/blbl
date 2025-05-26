import 'dart:convert';

class DynamicListResponse {
  final int code;
  final String message;
  final int ttl;
  final DynamicData data;

  DynamicListResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.data,
  });

  factory DynamicListResponse.fromJson(Map<String, dynamic> json) {
    return DynamicListResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      ttl: json['ttl'] ?? 0,
      data: DynamicData.fromJson(json['data'] ?? {}),
    );
  }

  static DynamicListResponse fromJsonString(String jsonString) {
    return DynamicListResponse.fromJson(json.decode(jsonString));
  }
}

class DynamicData {
  final bool hasMore;
  final String? offset;
  final List<DynamicItem> items;

  DynamicData({
    required this.hasMore,
    this.offset,
    required this.items,
  });

  factory DynamicData.fromJson(Map<String, dynamic> json) {
    final itemList = json['items'] as List<dynamic>? ?? [];
    return DynamicData(
      hasMore: json['has_more'] ?? false,
      offset: json['offset'],
      items: itemList.map((item) => DynamicItem.fromJson(item)).toList(),
    );
  }
}

class DynamicItem {
  final String idStr;
  final DynamicModules modules;
  final DynamicType type;
  final DynamicBasic basic;
  final DynamicOriginal? orig;

  DynamicItem({
    required this.idStr,
    required this.modules,
    required this.type,
    required this.basic,
    this.orig,
  });

  factory DynamicItem.fromJson(Map<String, dynamic> json) {
    return DynamicItem(
      idStr: json['id_str'] ?? '',
      modules: DynamicModules.fromJson(json['modules'] ?? {}),
      type: _parseDynamicType(json['type'] ?? ''),
      basic: DynamicBasic.fromJson(json['basic'] ?? {}),
      orig:
          json['orig'] != null ? DynamicOriginal.fromJson(json['orig']) : null,
    );
  }

  static DynamicType _parseDynamicType(String type) {
    switch (type) {
      case 'DYNAMIC_TYPE_FORWARD':
        return DynamicType.forward;
      case 'DYNAMIC_TYPE_DRAW':
        return DynamicType.draw;
      case 'DYNAMIC_TYPE_WORD':
        return DynamicType.word;
      case 'DYNAMIC_TYPE_AV':
        return DynamicType.video;
      case 'DYNAMIC_TYPE_LIVE':
        return DynamicType.live;
      case 'DYNAMIC_TYPE_ARTICLE':
        return DynamicType.article;
      default:
        return DynamicType.unknown;
    }
  }

  // Helper getter to determine the dynamic type
  DynamicType get dynamicType {
    if (modules.moduleDynamic?.major?.archive != null) {
      return DynamicType.archive;
    } else if (modules.moduleDynamic?.major?.draw != null) {
      return DynamicType.draw;
    } else if (modules.moduleDynamic?.major?.live != null) {
      return DynamicType.live;
    } else if (modules.moduleDynamic?.major?.article != null) {
      return DynamicType.article;
    } else if (modules.moduleDynamic?.major?.forward != null) {
      return DynamicType.forward;
    } else if (modules.moduleDynamic?.major?.text != null) {
      return DynamicType.text;
    } else {
      return DynamicType.unknown;
    }
  }
}

enum DynamicType {
  forward,
  draw,
  word,
  video,
  live,
  article,
  unknown,
  text,
  archive,
}

class DynamicBasic {
  final String commentIdStr;
  final int commentType;
  final String ridStr;
  final int timestamp;

  DynamicBasic({
    required this.commentIdStr,
    required this.commentType,
    required this.ridStr,
    required this.timestamp,
  });

  factory DynamicBasic.fromJson(Map<String, dynamic> json) {
    return DynamicBasic(
      commentIdStr: json['comment_id_str'] ?? '',
      commentType: json['comment_type'] ?? 0,
      ridStr: json['rid_str'] ?? '',
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

class DynamicOriginal {
  final DynamicBasic basic;
  final DynamicModules modules;

  DynamicOriginal({
    required this.basic,
    required this.modules,
  });

  factory DynamicOriginal.fromJson(Map<String, dynamic> json) {
    return DynamicOriginal(
      basic: DynamicBasic.fromJson(json['basic'] ?? {}),
      modules: DynamicModules.fromJson(json['modules'] ?? {}),
    );
  }
}

class DynamicModules {
  final ModuleAuthor moduleAuthor;
  final ModuleDesc? moduleDesc;
  final ModuleDynamic? moduleDynamic;
  final ModuleStat moduleStat;
  final ModulePic? modulePic;

  DynamicModules({
    required this.moduleAuthor,
    this.moduleDesc,
    this.moduleDynamic,
    required this.moduleStat,
    this.modulePic,
  });

  factory DynamicModules.fromJson(Map<String, dynamic> json) {
    return DynamicModules(
      moduleAuthor: ModuleAuthor.fromJson(json['module_author'] ?? {}),
      moduleDesc: json['module_dynamic'] != null
          ? ModuleDesc.fromJson(json[
              'module_dynamic']) // Assuming ModuleDesc is part of module_dynamic
          : null,
      moduleDynamic: json['module_dynamic'] != null
          ? ModuleDynamic.fromJson(
              json['module_dynamic']) // ModuleDynamic contains major
          : null,
      moduleStat: ModuleStat.fromJson(json['module_stat'] ?? {}),
      modulePic: json['module_dynamic']?['major']?['draw'] != null
          ? ModulePic.fromJson(json['module_dynamic']['major']['draw'])
          : null,
    );
  }
}

class ModuleAuthor {
  final String face;
  final bool faceNft;
  final int mid;
  final String name;
  final String jumpUrl;
  final OfficialVerify? officialVerify;

  ModuleAuthor({
    required this.face,
    required this.faceNft,
    required this.mid,
    required this.name,
    required this.jumpUrl,
    this.officialVerify,
  });

  factory ModuleAuthor.fromJson(Map<String, dynamic> json) {
    return ModuleAuthor(
      face: json['face'] ?? '',
      faceNft: json['face_nft'] ?? false,
      mid: json['mid'] ?? 0,
      name: json['name'] ?? '',
      jumpUrl: json['jump_url'] ?? '',
      officialVerify: json['official_verify'] != null
          ? OfficialVerify.fromJson(json['official_verify'])
          : null,
    );
  }
}

class OfficialVerify {
  final String desc;
  final int type;

  OfficialVerify({
    required this.desc,
    required this.type,
  });

  factory OfficialVerify.fromJson(Map<String, dynamic> json) {
    return OfficialVerify(
      desc: json['desc'] ?? '',
      type: json['type'] ?? -1,
    );
  }
}

class ModuleDesc {
  final String text;

  ModuleDesc({
    required this.text,
  });

  factory ModuleDesc.fromJson(Map<String, dynamic> json) {
    return ModuleDesc(
      text: json['desc']?['text'] ?? '',
    );
  }
}

class ModuleDynamic {
  final DynamicMajor? major;

  ModuleDynamic({
    this.major,
  });

  factory ModuleDynamic.fromJson(Map<String, dynamic> json) {
    return ModuleDynamic(
      major:
          json['major'] != null ? DynamicMajor.fromJson(json['major']) : null,
    );
  }
}

class DynamicMajor {
  final DynamicArchive? archive;
  final DynamicDraw? draw;
  final DynamicLive? live;
  final DynamicArticle? article;
  // Add other major types if needed, e.g., DynamicText, DynamicForward
  final DynamicText? text; // Assuming text dynamic has a major structure
  final DynamicForward?
      forward; // Assuming forward dynamic has a major structure

  DynamicMajor({
    this.archive,
    this.draw,
    this.live,
    this.article,
    this.text,
    this.forward,
  });

  factory DynamicMajor.fromJson(Map<String, dynamic> json) {
    return DynamicMajor(
      archive: json['archive'] != null
          ? DynamicArchive.fromJson(json['archive'])
          : null,
      draw: json['draw'] != null ? DynamicDraw.fromJson(json['draw']) : null,
      live: json['live'] != null ? DynamicLive.fromJson(json['live']) : null,
      article: json['article'] != null
          ? DynamicArticle.fromJson(json['article'])
          : null,
      text: json['text'] != null
          ? DynamicText.fromJson(json['text'])
          : null, // Assuming text dynamic has a major structure
      forward: json['forward'] != null
          ? DynamicForward.fromJson(json['forward'])
          : null, // Assuming forward dynamic has a major structure
    );
  }
}

class DynamicArchive {
  final String aid;
  final String bvid;
  final String title;
  final String desc;
  final String cover;
  final int duration;
  final String jumpUrl;

  DynamicArchive({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.desc,
    required this.cover,
    required this.duration,
    required this.jumpUrl,
  });

  factory DynamicArchive.fromJson(Map<String, dynamic> json) {
    return DynamicArchive(
      aid: json['aid'] ?? '',
      bvid: json['bvid'] ?? '',
      title: json['title'] ?? '',
      desc: json['desc'] ?? '',
      cover: json['cover'] ?? '',
      duration: json['duration'] ?? 0,
      jumpUrl: json['jump_url'] ?? '',
    );
  }
}

class DynamicDraw {
  final List<DynamicDrawItem> items;

  DynamicDraw({
    required this.items,
  });

  factory DynamicDraw.fromJson(Map<String, dynamic> json) {
    final itemList = json['items'] as List<dynamic>? ?? [];
    return DynamicDraw(
      items: itemList.map((item) => DynamicDrawItem.fromJson(item)).toList(),
    );
  }
}

class DynamicDrawItem {
  final String src;
  final int width;
  final int height;
  final List<String> tags;

  DynamicDrawItem({
    required this.src,
    required this.width,
    required this.height,
    required this.tags,
  });

  factory DynamicDrawItem.fromJson(Map<String, dynamic> json) {
    final tagsList = json['tags'] as List<dynamic>? ?? [];
    return DynamicDrawItem(
      src: json['src'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      tags: tagsList.map((e) => e.toString()).toList(),
    );
  }
}

class DynamicLive {
  final String title;
  final String cover;
  final int liveState;
  final ModuleAuthor author;

  DynamicLive({
    required this.title,
    required this.cover,
    required this.liveState,
    required this.author,
  });

  factory DynamicLive.fromJson(Map<String, dynamic> json) {
    return DynamicLive(
      title: json['title'] ?? '',
      cover: json['cover'] ?? '',
      liveState: json['live_state'] ?? 0,
      author: ModuleAuthor.fromJson(json['author'] ?? {}),
    );
  }
}

class DynamicArticle {
  final String title;
  final String desc;
  final List<String> covers;
  final String jumpUrl;

  DynamicArticle({
    required this.title,
    required this.desc,
    required this.covers,
    required this.jumpUrl,
  });

  factory DynamicArticle.fromJson(Map<String, dynamic> json) {
    final coversList = json['covers'] as List<dynamic>? ?? [];
    return DynamicArticle(
      title: json['title'] ?? '',
      desc: json['desc'] ?? '',
      covers: coversList.map((e) => e.toString()).toList(),
      jumpUrl: json['jump_url'] ?? '',
    );
  }
}

class DynamicText {
  final String content;

  DynamicText({
    required this.content,
  });

  factory DynamicText.fromJson(Map<String, dynamic> json) {
    return DynamicText(
      content: json['content'] ?? '',
    );
  }
}

class DynamicForward {
  // Forward dynamic might not have specific major fields beyond the original dynamic
  // If it does, add them here.
  // For now, it primarily relies on the 'orig' field in DynamicItem.

  DynamicForward(); // Constructor might be empty if no specific fields

  factory DynamicForward.fromJson(Map<String, dynamic> json) {
    // No specific fields to parse for now, based on common API structures
    return DynamicForward();
  }
}

class ModuleStat {
  final DynamicStat comment;
  final DynamicStat like;
  final DynamicStat play;
  final DynamicStat share;

  ModuleStat({
    required this.comment,
    required this.like,
    required this.play,
    required this.share,
  });

  factory ModuleStat.fromJson(Map<String, dynamic> json) {
    return ModuleStat(
      comment: DynamicStat.fromJson(json['comment'] ?? {}),
      like: DynamicStat.fromJson(json['like'] ?? {}),
      play: DynamicStat.fromJson(json['play'] ?? {}),
      share: DynamicStat.fromJson(json['share'] ?? {}),
    );
  }
}

class DynamicStat {
  final int count;
  final bool status;

  DynamicStat({
    required this.count,
    required this.status,
  });

  factory DynamicStat.fromJson(Map<String, dynamic> json) {
    return DynamicStat(
      count: json['count'] ?? 0,
      status: json['status']?? false,
    );
  }
}

class ModulePic {
  final List<DynamicDrawItem> items;

  ModulePic({
    required this.items,
  });

  factory ModulePic.fromJson(Map<String, dynamic> json) {
    final itemList = json['items'] as List<dynamic>? ?? [];
    return ModulePic(
      items: itemList.map((item) => DynamicDrawItem.fromJson(item)).toList(),
    );
  }
}

class FrequentUser {
  final int mid;
  final String face;
  final String name;

  FrequentUser({
    required this.mid,
    required this.face,
    required this.name,
  });

  factory FrequentUser.fromJson(Map<String, dynamic> json) {
    return FrequentUser(
      mid: json['mid'] ?? 0,
      face: json['face'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
