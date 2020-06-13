import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

Future<void> inject(
  WidgetTester tester,
  Widget widget, {
  int milliseconds,
}) async {
  await tester.pumpWidget(widget);
  if (milliseconds == null) {
    await tester.pumpAndSettle();
  } else {
    await tester.pumpAndSettle(Duration(milliseconds: milliseconds));
  }
}

Future<void> sleep(int milliseconds) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
  return;
}

class InMemoryStorage<T> extends MomentumService {
  final Map<String, T> _store = {};

  Future<bool> save(String key, T value) async {
    await sleep(1000);
    _store.addAll({key: value});
    var successfullySaved = _store.containsKey(key) && _store[key] == value;
    return successfullySaved;
  }

  T getValue(String key) {
    if (_store.containsKey(key)) {
      return _store[key];
    }
    return null;
  }
}

class DummyService extends MomentumService {}