import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import 'sleep.dart';

Map<String, InMemoryStorage> _persistedStorage = {};

class InMemoryStorage extends MomentumService {
  final Map<String, String> _stringStore = {};

  static InMemoryStorage of(String sessionKey, BuildContext context) {
    if (_persistedStorage.containsKey(sessionKey)) {
      return _persistedStorage[sessionKey];
    } else {
      var inMemoryStorage = Momentum.getService<InMemoryStorage>(context);
      _persistedStorage.addAll({sessionKey: inMemoryStorage});
      return inMemoryStorage;
    }
  }

  Future<bool> setString(String key, String value) async {
    await sleep(100); // mock delay
    _stringStore.addAll({key: value});
    var saved = _stringStore.containsKey(key) && _stringStore[key] == value;
    return saved;
  }

  String getString(String key) {
    if (_stringStore.containsKey(key)) {
      return _stringStore[key];
    }
    return null;
  }
}
