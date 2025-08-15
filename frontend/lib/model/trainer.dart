import 'package:poligon/model/path.dart';

/// Author: Łukasz Piętka (FUT 2025)
class Trainer {
  final int id;
  final String name;
  final TrainingPath path;
  final String description;
  final String imageUrl;
  final String trainings;
  final DateTime? lastModified;
  double imageAlignmentY;

  Trainer({
    required this.id,
    required this.name,
    required this.path,
    required this.description,
    required this.trainings,
    required this.imageUrl,
    this.lastModified,
    required this.imageAlignmentY,
  });
}
