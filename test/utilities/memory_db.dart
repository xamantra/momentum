import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import 'sleep.dart';

Map<String, dynamic> _persistedStorage = {};

class InMemoryStorage<T> extends MomentumService {
  final Map<String, T> _store = {};

  static InMemoryStorage<T> of<T>(String uniqueKey, BuildContext context) {
    if (_persistedStorage.containsKey(uniqueKey)) {
      return _persistedStorage[uniqueKey] as InMemoryStorage<T>;
    } else {
      var inMemoryStorage = Momentum.getService<InMemoryStorage<T>>(context);
      _persistedStorage.addAll({uniqueKey: inMemoryStorage});
      return inMemoryStorage;
    }
  }

  Future<bool> save(String key, T value) async {
    await sleep(100);
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