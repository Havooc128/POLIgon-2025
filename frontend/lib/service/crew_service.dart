import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:poligon/model/crew.dart';
import 'package:poligon/service/base_api_service.dart';

import '../model/path.dart';

/// Author: Łukasz Piętka (FUT 2025)
class CrewService extends BaseApiService<Crew> {
  @override
  String get basePath => "crew";

  @override
  String hiveBoxName({TrainingPath? path}) => "crew";

  Crew? _cache;

  Future<Crew?> getMe({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      return _cache!;
    }

    final box = await Hive.openBox("${hiveBoxName}_me");

    if (!forceRefresh && box.isNotEmpty) {
      final cached = await box.getAt(0);
      final me = fromJson(jsonDecode(cached));
      _cache = me;
      return me;
    }

    try {
      final response = await dio.get("$basePath/me");
      final me = fromJson(response.data);
      _cache = me;

      await box.clear();
      box.add(jsonEncode(toJson(me)));

      return me;
    } catch (e) {
      return null;
    }
  }

  @override
  Crew fromJson(Map<String, dynamic> json) {
    return Crew(
      id: json['id']??-1,
      name: json['name'] as String,
      room: json['room'] as String,
      role: json['role'] as String,
      imageUrl: json['imageUrl'] as String,
      sobrietyDay: DateTime.parse(json['sobrietyDay'] as String),
      description: json['description'] as String,
      crewQuest: json['crewQuest'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      isSuperAdmin: json['superAdmin'] as bool,
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified'] as String) : null,
      imageAlignmentY: json['imageAlignmentY']
    );
  }

  @override
  Map<String, dynamic> toJson(Crew c) => {
    'id': c.id,
    'name': c.name,
    'room': c.room,
    'role': c.role,
    'imageUrl': c.imageUrl,
    'sobrietyDay': c.sobrietyDay.toIso8601String().split('T').first,
    'description': c.description,
    'crewQuest': c.crewQuest,
    'phoneNumber': c.phoneNumber,
    'email': c.email,
    'superAdmin': c.isSuperAdmin,
    'imageAlignmentY': c.imageAlignmentY
  };

}