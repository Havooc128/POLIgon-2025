import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../model/schedule_day.dart';
import '../model/path.dart';
import '../service/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  ScheduleService _service = ScheduleService();
  late Box _box;
  List<ScheduleDay> _days = [];
  List<ScheduleDay> get days => _days;
  TrainingPath? _currentPath;
  TrainingPath? get path => _currentPath;

  ScheduleProvider() {
    init();
  }

  void init() async {
    _box = await Hive.openBox("schedule_id");
    if(_box.isEmpty || _box.get('id') == null) {
      await _load(TrainingPath.wspolpraca);
    }
    await _load(TrainingPath.pathFromString(_box.get("id")));
  }


  /// Inicjalizuj plan dla ścieżki
  Future<void> _load(TrainingPath path) async {
    _days = await _service.getByPath(path);
    _box.put('id', path.backendLabel);
    _currentPath = path;
    notifyListeners();
    await _service.startListening();

    _service.onDataUpdated.listen((list) {
      _days = list.where((d) => d.path == path).toList();
      notifyListeners();
    });
  }

  Future<void> load(TrainingPath path) async {
    _service.stopListening();
    _service = ScheduleService();
    _days = await _service.getByPath(path);
    _box.put('id', path.backendLabel);
    _currentPath = path;

    await _service.startListening();
    _service.onDataUpdated.listen((list) {
      _days = list.where((d) => d.path == path).toList();
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_currentPath != null) {
      _days = await _service.getByPath(_currentPath!);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _service.stopListening();
    _box.close();
    super.dispose();
  }

}
