import 'package:poligon/model/team.dart';
import 'package:poligon/service/base_api_service.dart';

import '../model/path.dart';

/// Author: Łukasz Piętka (FUT 2025)
class TeamService extends BaseApiService<Team> {
  @override
  String get basePath => "teams";

  @override
  String hiveBoxName({TrainingPath? path}) => "teams";

  @override
  Team fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'] as String,
      captainName: json['captainName'] ?? 'Brak',
      members: (json['members'] as List?)?.map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String,
      points: json['points'] ?? 0,
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson(Team t) {
    return {
      'id': t.id,
      'name': t.name,
      'captainName': t.captainName,
      'members': t.members,
      'imageUrl': t.imageUrl,
      'points': t.points,
    };
  }

}