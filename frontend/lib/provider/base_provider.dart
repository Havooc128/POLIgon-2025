import 'package:flutter/material.dart';
import '../service/base_api_service.dart';

/// Author: Łukasz Piętka (FUT 2025)
class BaseNotifier<T> with ChangeNotifier {
  final BaseApiService<T> service;

  List<T> _items = [];
  List<T> get items => _items;

  BaseNotifier(this.service) {
    init();
  }

  Future<void> init() async {
    _items = await service.getAll();
    notifyListeners();

    await service.startListening();

    service.onDataUpdated.listen((list) {
      _items = list;
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    _items = await service.getAll();
    notifyListeners();
  }

  @override
  void dispose() {
    service.stopListening();
    super.dispose();
  }
}
