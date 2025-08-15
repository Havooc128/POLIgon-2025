import 'package:poligon/model/announcement.dart';
import 'package:poligon/service/base_api_service.dart';

import '../model/path.dart';
import 'crew_service.dart';

/// Author: Łukasz Piętka (FUT 2025)
class AnnouncementService extends BaseApiService<Announcement> {
  @override
  String get basePath => "announcements";

  @override
  String hiveBoxName({TrainingPath? path}) => "announcements";

  @override
  Announcement fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      text: json['text'] as String,
      author: CrewService().fromJson(json['author'] as Map<String, dynamic>),
      publishDate: DateTime.parse(json['publishDate'] as String),
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson(Announcement a) => {
    'id': a.id,
    'text': a.text,
    'publishDate': a.publishDate.toIso8601String(),
    'author': CrewService().toJson(a.author),
  };
}