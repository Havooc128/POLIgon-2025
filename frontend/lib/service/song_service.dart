import 'package:poligon/model/song.dart';
import 'package:poligon/service/base_api_service.dart';

import '../model/path.dart';

/// Author: Łukasz Piętka (FUT 2025)
class SongService extends BaseApiService<Song> {
  @override
  String get basePath => "songbook";

  @override
  String hiveBoxName({TrainingPath? path}) => "announcements";

  @override
  Song fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'] as String,
      songText: json['songText'] as String,
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson(Song s) {
    return {
      'id': s.id,
      'title': s.title,
      'songText': s.songText,
    };
  }

}