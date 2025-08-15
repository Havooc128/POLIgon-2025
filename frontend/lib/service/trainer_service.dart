import 'package:poligon/model/trainer.dart';
import 'package:poligon/service/base_api_service.dart';

import '../model/path.dart';

/// Author: Łukasz Piętka (FUT 2025)
class TrainerService extends BaseApiService<Trainer>{
  @override
  String get basePath => "trainers";

  @override
  String hiveBoxName({TrainingPath? path}) => "announcements";

  @override
  Trainer fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['id'],
      name: json['name'] as String,
      path: TrainingPath.pathFromString(json['path']),
      description: json['description'] as String,
      trainings: json['trainings'] as String,
      imageUrl: json['imageUrl'] as String,
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified'] as String) : null,
      imageAlignmentY: json['imageAlignmentY'],
    );
  }

  @override
  Map<String, dynamic> toJson(Trainer t) {
    return {
      'id': t.id,
      'name': t.name,
      'path': t.path.backendLabel,
      'description': t.description,
      'trainings': t.trainings,
      'imageUrl': t.imageUrl,
      'imageAlignmentY': t.imageAlignmentY,
    };
  }

}
