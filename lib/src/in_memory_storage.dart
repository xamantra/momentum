import 'package:flutter/material.dart';

import 'momentum_base.dart';

Map<String, InMemoryStorage> _persistedStorage = {};

/// In memory database service for mocking persistence.
class InMemoryStorage extends MomentumService {
  final Map<String, String> _stringStore = {};

  /// Get an instance of `InMemoryStorage` from services using context.
  static InMemoryStorage of(String sessionKey, BuildContext context) {
    if (_persistedStorage.containsKey(sessionKey)) {
      return _persistedStorage[sessionKey];
    } else {
      InMemoryStorage inMemoryStorage;
      if (context != null) {
        inMemoryStorage = Momentum.getService<InMemoryStorage>(context);
      } else {
        inMemoryStorage = InMemoryStorage();
      }
      _persistedStorage.putIfAbsent(sessionKey, () => inMemoryStorage);
      return _persistedStorage[sessionKey];
    }
  }

  /// Saves a string [value] to memory which
  /// will be gone when the program is terminated.
  bool setString(String key, String value) {
    _stringStore.addAll({key: value});
    var saved = _stringStore.containsKey(key) && _stringStore[key] == value;
    return saved;
  }

  /// Reads a value from persistent storage.
  String getString(String key) {
    if (_stringStore.containsKey(key)) {
      return _stringStore[key];
    }
    return null;
  }
}
