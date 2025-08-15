import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:poligon/model/schedule_day.dart';
import 'package:poligon/service/base_api_service.dart';
import 'package:poligon/service/dio_service.dart';

import '../model/path.dart';
import '../model/schedule_element.dart';

/// Author: Łukasz Piętka (FUT 2025)
class ScheduleService extends BaseApiService<ScheduleDay> {
  final Dio _dio = DioService().dio;

  @override
  String get basePath => "schedule";

  @override
  TrainingPath? additionalId = TrainingPath.wspolpraca;

  /// Klucz cache w Hive — kluczujesz ścieżką, np. `schedule_0` itp.
  @override
  String hiveBoxName({TrainingPath? path}) => "schedule_${path?.index}";

  Future<List<ScheduleDay>> getByPath(TrainingPath path) async {
    additionalId = path;
    final box = await Hive.openBox(hiveBoxName(path: path));
    String? timestampBox = box.get('timestamp-$basePath');
    DateTime? timestamp = timestampBox != null ? DateTime.parse(timestampBox) : null;

    try {
      final response = await _dio.get('$basePath/${path.name.toUpperCase()}', queryParameters: timestamp != null ? {'lastUpdated': timestamp.toIso8601String()} : null);

      if(response.data == null || (response.data is List && (response.data as List).isEmpty || (response.data is Map && response.data.isEmpty))) {
        print('$basePath: No data found');
        box.clear();
        return Future.value([]);
      }

      if (response.statusCode == HttpStatus.notModified) {
        final rawCached = box.get('data-$basePath');
        if (rawCached != null && rawCached is List) {
          final cached = rawCached.map((e) => e.toString()).toList();
          print('$basePath: Not modified; cache returned');
          final parsed = cached.map((e) => fromJson(jsonDecode(e))).toList();
          return parsed; // OK
        }
      }

      final data = response.data as List;

      final list =
      data.map((json) => fromJson(json as Map<String, dynamic>)).toList();

      await box.put('data-$basePath', list.map((e) => jsonEncode(toJson(e))).toList());

      await box.put("timestamp-$basePath", (getLastModifiedDate(list) ?? DateTime.now().subtract(Duration(days: 1))).toIso8601String());
      print('$basePath: Modified; request response returned');
      return list;
    } catch (e) {
      final rawCached = box.get('data-$basePath');
      if (rawCached != null && rawCached is List) {
        final cached = rawCached.map((e) => e.toString()).toList();
        if (cached.isNotEmpty) {
          print('$basePath: Failed to fetch data via request, cache returned...');
          final parsed = cached.map((e) => fromJson(jsonDecode(e))).toList();
          return parsed; // OK
        }
      }
      rethrow;
    }
  }

  /// POST na liście dni (backend przyjmuje List<ScheduleDay>)
  Future<void> saveAll(List<ScheduleDay> days) async {
    try {
      await _dio.post(basePath, data: days.map((d) => toJson(d)).toList());
      // Wyczyszczenie cache’a dla tej ścieżki
      for (var day in days) {
        final box = await Hive.openBox(hiveBoxName(path: day.path));
        await box.clear();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  ScheduleDay fromJson(Map<String, dynamic> json) {
    return ScheduleDay(
      id: json['id'] as int,
      day: DateTime.parse(json['day'] as String),
      path: TrainingPath.pathFromString(json['schedulePath']),
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified'] as String) : null,
      elements: (json['elements'] as List).isEmpty ? [] :
          (json['elements'] as List)
              .map((e) => ScheduleElement.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson(ScheduleDay s) {
    return {
      'id': s.id,
      'day': s.day.toIso8601String().split('T').first,
      'schedulePath': s.path.backendLabel,
      'elements': s.elements.map((e) => e.toJson()).toList(),
    };
  }
}
