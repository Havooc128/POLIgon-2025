import 'package:flutter/material.dart';

/// Author: Łukasz Piętka (FUT 2025)
class ScheduleElement {
  final int id;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String description;

  ScheduleElement({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.description,
  });

  factory ScheduleElement.fromJson(Map<String, dynamic> json) {
    return ScheduleElement(
      id: json['id'] ?? 0,
      startTime: _parseTime(json['startTime'] as String),
      endTime: _parseTime(json['endTime'] as String),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': _formatTime(startTime),
      'endTime': _formatTime(endTime),
      'description': description,
    };
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}