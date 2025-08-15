import 'package:poligon/model/path.dart';
import 'package:poligon/model/schedule_element.dart';

/// Author: Łukasz Piętka (FUT 2025)
class ScheduleDay {
  final int id;
  final DateTime day;
  final TrainingPath path;
  final List<ScheduleElement> elements;
  final DateTime? lastModified;

  ScheduleDay({required this.id, required this.day, this.path = TrainingPath.wspolpraca, required this.elements, this.lastModified});
}
