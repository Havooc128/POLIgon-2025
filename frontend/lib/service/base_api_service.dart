import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:poligon/service/web_socket_service.dart';

import '../model/path.dart';
import 'dio_service.dart';

/// Author: Łukasz Piętka (FUT 2025)
abstract class BaseApiService<T> {
  final Dio dio = DioService().dio;

  /// Hive box key
  String hiveBoxName({TrainingPath? path});

  /// API base path, np. "announcements"
  String get basePath;

  TrainingPath? additionalId;

  String get wsPath => (additionalId == null ? basePath : "$basePath-${additionalId!.backendLabel}").split('/').last;

  /// Deserializacja
  T fromJson(Map<String, dynamic> json);

  /// Serializacja
  Map<String, dynamic> toJson(T entity);

  final StreamController<List<T>> _dataUpdatedController = StreamController.broadcast();

  Stream<List<T>> get onDataUpdated => _dataUpdatedController.stream;

  final WebSocketService socketService = WebSocketService();

  /// Uruchom WS listener
  Future<void> startListening() async {
    socketService.connect();

    socketService.registerHandler(wsPath, (event) async {
      final box = await Hive.openBox(hiveBoxName());

      final List decoded = event['payload'] as List;
      final list = decoded.map((e) => fromJson(e)).toList();

      await box.put('data-$basePath', list.map((e) => jsonEncode(toJson(e))).toList());
      await box.put("timestamp-$basePath", (getLastModifiedDate(list) ?? DateTime.now().subtract(Duration(days: 1))).toIso8601String());

      _dataUpdatedController.add(list);
      print("Updated cache for $basePath via WS");
    });
  }

  void stopListening() {
    _dataUpdatedController.close();
    socketService.unregisterHandler(wsPath);
  }

  Future<List<T>> getAll() async {
    final box = await Hive.openBox(hiveBoxName());
    String? timestampBox = box.get('timestamp-$basePath');
    DateTime? timestamp = timestampBox != null ? DateTime.parse(timestampBox) : null;

    try {
      final response = await dio.get(basePath,
          queryParameters: timestamp != null ? {
            'lastUpdated': timestamp.toIso8601String()
          } : null);
      if (response.data == null ||
          (response.data is List && (response.data as List).isEmpty ||
              (response.data is Map && response.data.isEmpty))) {
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
      final list = data.map((json) => fromJson(json)).toList();

      await box.put(
          'data-$basePath', list.map((e) => jsonEncode(toJson(e))).toList());

      await box.put("timestamp-$basePath", (getLastModifiedDate(list) ??
          DateTime.now().subtract(Duration(days: 1))).toIso8601String());
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

  DateTime? getLastModifiedDate(List data) {
    if (data.isEmpty) {
      return null;
    }

    if (data.length == 1) {
      return data[0].lastModified;
    }

    return data
        .map((e) => e?.lastModified)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }


  /// Wyczyść cache
  void clearCache() async {
    final box = await Hive.openBox(hiveBoxName());
    await box.clear();
  }

  /// Zapisz lub zaktualizuj encję
  Future<void> saveOrUpdate(T entity) async {
    try {
      await dio.post(basePath, data: jsonEncode(toJson(entity)));
    } catch (e) {
      print('$basePath: nie udało się zapisać zmian w bazie $e');
    }
  }

  /// Usuń encję po id
  Future<void> delete(int id) async {
    try {
      await dio.delete('$basePath/$id');
    } catch (e) {
      print('$basePath: nie udało się zapisać zmian w bazie $e');
    }
  }
}
