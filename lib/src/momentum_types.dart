import 'package:flutter/material.dart';

import 'momentum_base.dart';

typedef MomentumSnapshot<T> = T Function<T extends MomentumModel>([Type]);

typedef MomentumBuilderFunction = Widget Function(
  BuildContext,
  MomentumSnapshot,
);

typedef ResetAll = void Function(
  BuildContext,
  void Function(BuildContext) resetAll,
);

typedef BuildSkipper = bool Function(
  T Function<T extends MomentumController>(),
  bool isTimeTravel,
);

typedef PersistSaver = Future<bool> Function(
  BuildContext context,
  String key,
  String value,
);

typedef PersistGet = Future<String> Function(
  BuildContext context,
  String key,
);

typedef PersistSaverSync = bool Function(
  BuildContext context,
  String key,
  String value,
);

typedef PersistGetSync = String Function(
  BuildContext context,
  String key,
);
