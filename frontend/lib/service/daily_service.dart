import 'package:poligon/model/announcement.dart';
import 'package:poligon/service/base_api_service.dart';

import '../model/path.dart';
import 'crew_service.dart';

/// Author: Łukasz Piętka (FUT 2025)
class DailyQuestService extends BaseApiService<Announcement> {
  @override
  String get basePath => "daily";

  @override
  String hiveBoxName({TrainingPath? path}) => "daily";

  @override
  Announcement fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      text: json['message'] as String,
      author: CrewService().fromJson(json['addedBy'] as Map<String, dynamic>),
      publishDate: DateTime.parse(json['day'] as String),
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson(Announcement a) => {
    'id': a.id,
    'message': a.text,
    'day': a.publishDate.toIso8601String().split('T').first,
    'addedBy': CrewService().toJson(a.author),
  };
}