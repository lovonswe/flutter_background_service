import 'package:flutter/material.dart';

class StateManager extends ChangeNotifier {
  static final StateManager _instance = StateManager._internal();
  int _okCount = 0;
  int _notOkCount = 0;

  factory StateManager() {
    return _instance;
  }

  StateManager._internal();

  int get okCount => _okCount;
  int get notOkCount => _notOkCount;

  void updateCounts(int okCount, int notOkCount) {
    _okCount = okCount;
    _notOkCount = notOkCount;
    notifyListeners();
  }
}
